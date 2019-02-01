import boto3
import json
import uuid
import retrying


role_document = {
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "apigateway.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    },
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }
  ]
}


def deploy_core_service(args):
    account_user = getAccountUser(args.aws_accesskey, args.aws_secretkey)
    account_user_arn = getAccountUserArn(args.aws_accesskey, args.aws_secretkey)
    account_id = getAccountId(args.aws_accesskey, args.aws_secretkey)
    credential_id = "MultiAccount"+account_id
    # prepare account json with account and regions
    account_json = {"ACCOUNTID": account_id,
                    "CREDENTIAL_ID": credential_id,
                    "IAM": {},
                    "REGIONS": []
                    }
    # loop multiple regions and each region-account, create
    for item in args.aws_region:
        api_client = boto3.client('apigateway',
                                  aws_access_key_id=args.aws_accesskey,
                                  aws_secret_access_key=args.aws_secretkey,
                                  region_name=item)
        # 3 API Gateway endpoints (DEV/STG/PROD) per account/region
        api_prod = createapi('%s-prod' % (args.jazz_stackprefix), 'PROD', api_client)
        api_stg = createapi('%s-stg' % (args.jazz_stackprefix), 'STG', api_client)
        api_dev = createapi('%s-dev' % (args.jazz_stackprefix), 'DEV', api_client)
        # 3 deployment-buckets (DEV/STG/PROD)  per account/region for sls to store deployment artifacts
        bucket_client = boto3.client('s3',
                                     aws_access_key_id=args.aws_accesskey,
                                     aws_secret_access_key=args.aws_secretkey,
                                     region_name=item)
        bucket_prod = createbucket(args.jazz_stackprefix, 'prod', item, bucket_client)
        bucket_stg = createbucket(args.jazz_stackprefix, 'stg', item, bucket_client)
        bucket_dev = createbucket(args.jazz_stackprefix, 'dev', item, bucket_client)

        # New OAI (origin access identity)
        oai_client = boto3.client('cloudfront',
                                  aws_access_key_id=args.aws_accesskey,
                                  aws_secret_access_key=args.aws_secretkey,
                                  region_name=item)
        oai_id = createoai(oai_client, "%soai" % (args.jazz_stackprefix))
        account_json["REGIONS"].append({"REGION": item,
                                        "API_GATEWAY": {"PROD": api_prod, "STG": api_stg, "DEV": api_dev},
                                        "S3": {"PROD": bucket_prod, "STG": bucket_stg, "DEV": bucket_dev},
                                        "CLOUDFRONT": {"CLOUDFRONT_ORIGIN_ID": oai_id}})
        # Prepare assume role for each regions
        # Add a trust policy to the "logs destination"
        role_document['Statement'].append({
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.%s.amazonaws.com" % (item)
            },
            "Action": "sts:AssumeRole"
        })
    iam_client = boto3.client('iam',
                              aws_access_key_id=args.aws_accesskey,
                              aws_secret_access_key=args.aws_secretkey)
    # Basic IAM role with minimum permissions (cloudwatch:*)
    basic_role_arn = createbasicrole(iam_client, "%s_basic_execution" % (args.jazz_stackprefix), role_document)
    # One platform IAM role for the new account to use for integrations within the new account
    platform_role_arn = createplatformrole(iam_client, "%s_platform_services" % (args.jazz_stackprefix), role_document)
    account_json['IAM'] = {"USER": account_user,
                           "USER_ARN": account_user_arn,
                           "PLATFORMSERVICES_ROLEID": platform_role_arn,
                           "USERSERVICES_ROLEID": basic_role_arn,
                           }

    return account_json, credential_id


def getAccountUser(accessKey, secretKey):
    obj_iam = boto3.resource('iam', aws_access_key_id=accessKey, aws_secret_access_key=secretKey)
    return obj_iam.CurrentUser().user_name


def getAccountUserArn(accessKey, secretKey):
    obj_iam = boto3.resource('iam', aws_access_key_id=accessKey, aws_secret_access_key=secretKey)
    return obj_iam.CurrentUser().arn


def getAccountId(accessKey, secretKey):
    return boto3.client('sts',
                        aws_access_key_id=accessKey,
                        aws_secret_access_key=secretKey).get_caller_identity().get('Account')


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def createapi(name, description, api_client):
    api_response = api_client.create_rest_api(
                        name=name,
                        description=description,
     )
    return api_response['id']


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def createbucket(prefix, stage, region, bucket_client):
    bucket_name = prepare_bucket_name(prefix, stage)
    canonical_id = bucket_client.list_buckets()['Owner']['ID']
    if region != 'us-east-1':
        bucket_client.create_bucket(
                    Bucket=bucket_name,
                    CreateBucketConfiguration={'LocationConstraint': region},
                    GrantFullControl="id=%s,uri=http://acs.amazonaws.com/groups/s3/LogDelivery" % (canonical_id)
        )
    else:
        bucket_client.create_bucket(
                    Bucket=bucket_name,
                    GrantFullControl="id=%s,uri=http://acs.amazonaws.com/groups/s3/LogDelivery" % (canonical_id)
        )
    bucket_client.put_bucket_cors(
        Bucket=bucket_name,
        CORSConfiguration={
            'CORSRules': [
                {
                    'AllowedHeaders': [
                        'Authorization',
                    ],
                    'AllowedMethods': [
                        'GET',
                    ],
                    'AllowedOrigins': [
                        '*',
                    ],
                    'MaxAgeSeconds': 3000
                },
            ]
            })
    return bucket_name


def prepare_bucket_name(prefix, stage):
    return ''.join(["%s-%s-" % (prefix, stage), str(uuid.uuid4().hex)])


def createrole(iamclient, name, role_document):
    response = iamclient.create_role(
                RoleName=name,
                AssumeRolePolicyDocument=json.dumps(role_document)
    )
    return response['Role']['Arn']


def attach_role(iamclient, name, policyarn):
    iamclient.attach_role_policy(
            RoleName=name,
            PolicyArn=policyarn
            )


def createbasicrole(iamclient, name, role_document):
    role_arn = createrole(iamclient, name, role_document)
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole')

    return role_arn


def createplatformrole(iamclient, name, role_document):
    role_arn = createrole(iamclient, name, role_document)
    role_inline = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "iam:PassRole"
                        ],
                    "Effect": "Allow",
                    "Resource": "*"
                }
                ]
                }
    iamclient.put_role_policy(
             RoleName=name,
             PolicyName='%s_platform_service_policy' % (name),
             PolicyDocument=json.dumps(role_inline)
             )
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/AWSLambdaFullAccess')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/AmazonKinesisFullAccess')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/AmazonS3FullAccess')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/AmazonSQSFullAccess')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/AmazonCognitoPowerUser')
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs')

    return role_arn


def createoai(oai_client, name):
    response = oai_client.create_cloud_front_origin_access_identity(
                CloudFrontOriginAccessIdentityConfig={
                    'CallerReference': name,
                    'Comment': name
                }
                )
    return "origin-access-identity/cloudfront/%" % (response['CloudFrontOriginAccessIdentity']['Id'])
