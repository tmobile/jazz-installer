import boto3
import json
import uuid
import retrying

from utils.api_config import get_config, update_config_in


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


def deploy_core_service(aws_accesskey, aws_secretkey, jazz_username, jazz_password,
                        jazz_apiendpoint, aws_region, jazz_stackprefix, tags):
    global role_document
    account_id = getAccountId(aws_accesskey, aws_secretkey)
    account_name = getAccountName(aws_accesskey, aws_secretkey)
    credential_id = "MultiAccount"+account_id
    get_configjson = get_config(jazz_username, jazz_password, jazz_apiendpoint)
    account_info = get_configjson['data']['config']['AWS']['ACCOUNTS']
    # Check if the account is already present
    if any(accnt['ACCOUNTID'] == account_id for accnt in account_info):
        match = next((index for (index, accnts) in enumerate(account_info) if accnts["ACCOUNTID"] == account_id), None)
        platform_role_arn = account_info[match]["IAM"]["PLATFORMSERVICES_ROLEID"]
        iam_client = boto3.client('iam',
                                  aws_access_key_id=aws_accesskey,
                                  aws_secret_access_key=aws_secretkey)
        # loop through the REGIONS and call REGIONS append API
        for existing_item in aws_region:
            region_resources = create_region_resources(existing_item, get_configjson, tags, platform_role_arn,
                                                       aws_accesskey, aws_secretkey, jazz_stackprefix)
            # update IAM Assume policy for new region
            role_det = iam_client.get_role(
                RoleName='%s_platform_services' % (jazz_stackprefix),
            )
            existing_policy_document = role_det['Role']['AssumeRolePolicyDocument']["Statement"]
            policy_document = {
              "Version": "2012-10-17",
              "Statement": existing_policy_document
            }
            policy_document["Statement"].append({
                "Effect": "Allow",
                "Principal": {
                    "Service": "logs.%s.amazonaws.com" % (existing_item)
                },
                "Action": "sts:AssumeRole"
            })

            iam_client.update_assume_role_policy(
                RoleName='%s_platform_services' % (jazz_stackprefix),
                PolicyDocument=json.dumps(policy_document)
            )
            region_json = {"REGION": existing_item,
                           "API_GATEWAY": region_resources["API_GATEWAY"],
                           "S3": region_resources["S3"],
                           "LOGS": region_resources["LOGS"],
                           "SECURITY_GROUP_IDS": "REPLACEME",
                           "SUBNET_IDS": "REPLACEME"}
            query_url = '?id=ACCOUNTID&path=AWS.ACCOUNTS&value=%s' % (account_id)
            update_config_in("REGIONS", region_json, jazz_username,
                             jazz_password, jazz_apiendpoint, query_url)
        return '', credential_id

    # if no, ie no account information is there, then continue
    # prepare account json with account and regions
    account_json = {"ACCOUNTID": account_id,
                    "ACCOUNTNAME": account_name,
                    "CREDENTIAL_ID": credential_id,
                    "IAM": {},
                    "CLOUDFRONT": {},
                    "REGIONS": []
                    }
    for item in aws_region:
        # Prepare assume role for each regions
        # Add a trust policy to the "logs destination"
        role_document['Statement'].append({
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.%s.amazonaws.com" % (item)
            },
            "Action": "sts:AssumeRole"
        })
    # New OAI (origin access identity)
    oai_client = boto3.client('cloudfront',
                              aws_access_key_id=aws_accesskey,
                              aws_secret_access_key=aws_secretkey)
    oai_id = createoai(oai_client, "%soai" % (jazz_stackprefix))
    account_json["CLOUDFRONT"] = {"CLOUDFRONT_ORIGIN_ID": oai_id}

    iam_client = boto3.client('iam',
                              aws_access_key_id=aws_accesskey,
                              aws_secret_access_key=aws_secretkey)
    # Basic IAM role with minimum permissions (cloudwatch:*)
    basic_role_arn = createbasicrole(iam_client, "%s_basic_execution" % (jazz_stackprefix), role_document, tags)
    # One platform IAM role for the new account to use for integrations within the new account
    primary_account = get_configjson['data']['config']['AWS']["ACCOUNTS"][0]['ACCOUNTID']
    role_document['Statement'].append({
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::%s:role/%s_platform_services" % (primary_account, jazz_stackprefix)
        },
        "Action": "sts:AssumeRole"
     })

    platform_role_arn = createplatformrole(iam_client, "%s_platform_services" % (jazz_stackprefix),
                                           role_document, tags)
    # update permission policy on Primary Account
    if(platform_role_arn):
        updatePrimaryRole(platform_role_arn, jazz_stackprefix, account_id)

    account_json['IAM'] = {
                           "PLATFORMSERVICES_ROLEID": platform_role_arn,
                           "USERSERVICES_ROLEID": basic_role_arn,
                           }
    # loop multiple regions and each region-account, create

    for item in aws_region:
        region_resources = create_region_resources(item, get_configjson, tags, platform_role_arn,
                                                   aws_accesskey, aws_secretkey, jazz_stackprefix)

        account_json["REGIONS"].append({"REGION": item,
                                        "API_GATEWAY": region_resources["API_GATEWAY"],
                                        "S3": region_resources["S3"],
                                        "LOGS": region_resources["LOGS"],
                                        "SECURITY_GROUP_IDS": "REPLACEME",
                                        "SUBNET_IDS": "REPLACEME"})

    return account_json, credential_id


def create_region_resources(region, get_configjson, tags, platform_role_arn,
                            aws_accesskey, aws_secretkey, jazz_stackprefix):
    api_client = boto3.client('apigateway',
                              aws_access_key_id=aws_accesskey,
                              aws_secret_access_key=aws_secretkey,
                              region_name=region)
    # 3 API Gateway endpoints (DEV/STG/PROD) per account/region
    api_prod = createapi('%s-prod' % (jazz_stackprefix), 'PROD', api_client)
    api_stg = createapi('%s-stg' % (jazz_stackprefix), 'STG', api_client)
    api_dev = createapi('%s-dev' % (jazz_stackprefix), 'DEV', api_client)
    # 3 deployment-buckets (DEV/STG/PROD)  per account/region for sls to store deployment artifacts
    bucket_client = boto3.client('s3',
                                 aws_access_key_id=aws_accesskey,
                                 aws_secret_access_key=aws_secretkey,
                                 region_name=region)
    bucket_prod = createbucket(jazz_stackprefix, 'prod', region, bucket_client, tags, platform_role_arn)
    bucket_stg = createbucket(jazz_stackprefix, 'stg', region, bucket_client, tags, platform_role_arn)
    bucket_dev = createbucket(jazz_stackprefix, 'dev', region, bucket_client, tags, platform_role_arn)
    # Prepare destination arn for regions
    destarn_dict = preparelogdestion(region, get_configjson, jazz_stackprefix,
                                     getAccountId(aws_accesskey, aws_secretkey))

    return {"API_GATEWAY": {"PROD": {"*": api_prod}, "STG": {"*": api_stg}, "DEV": {"*": api_dev}},
            "S3": {"PROD": bucket_prod, "STG": bucket_stg, "DEV": bucket_dev}, "LOGS": destarn_dict}


def getAccountId(accessKey, secretKey):
    return boto3.client('sts',
                        aws_access_key_id=accessKey,
                        aws_secret_access_key=secretKey).get_caller_identity().get('Account')


def getAccountName(accessKey, secretKey):
    return boto3.client('iam',
                        aws_access_key_id=accessKey,
                        aws_secret_access_key=secretKey).list_account_aliases()['AccountAliases'][0]


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def createapi(name, description, api_client):
    api_response = api_client.create_rest_api(
                        name=name,
                        description=description,
     )
    return api_response['id']


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def createbucket(prefix, stage, region, bucket_client, tags, role_arn):
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
    put_bucket_policy(bucket_client, bucket_name, role_arn)
    put_bucket_core(bucket_client, bucket_name)
    put_tagging(bucket_client, bucket_name, tags)
    return bucket_name


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def put_bucket_policy(bucket_client, bucket_name, role_arn):
    policy_doc = {
        "Version": "2012-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Principal": {
                    "AWS": role_arn
                },
                "Action": "s3:*",
                "Resource": "arn:aws:s3:::%s/*" % (bucket_name)
            },
            {
                "Sid": "",
                "Effect": "Allow",
                "Principal": {
                    "AWS": role_arn
                },
                "Action": "s3:ListBucket",
                "Resource": "arn:aws:s3:::%s" % (bucket_name)
            }
        ]
    }
    bucket_client.put_bucket_policy(
        Bucket=bucket_name,
        Policy=json.dumps(policy_doc)
    )


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def put_bucket_core(bucket_client, bucket_name):
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


@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def put_tagging(bucket_client, bucket_name, tags):
    bucket_client.put_bucket_tagging(
        Bucket=bucket_name,
        Tagging={
            'TagSet': tags
        }
    )


def prepare_bucket_name(prefix, stage):
    return ''.join(["%s-%s-" % (prefix, stage), str(uuid.uuid4().hex)])


def createrole(iamclient, name, role_document, tags):
    response = iamclient.create_role(
                RoleName=name,
                AssumeRolePolicyDocument=json.dumps(role_document),
                Tags=tags
    )
    return response['Role']['Arn']


def attach_role(iamclient, name, policyarn):
    iamclient.attach_role_policy(
            RoleName=name,
            PolicyArn=policyarn
            )


def createbasicrole(iamclient, name, role_document, tags):
    role_arn = createrole(iamclient, name, role_document, tags)
    attach_role(iamclient, name, 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole')

    return role_arn


def createplatformrole(iamclient, name, role_document, tags):
    role_arn = createrole(iamclient, name, role_document, tags)
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
                    'CallerReference': "%s%s" % (name,  str(uuid.uuid4().hex)),
                    'Comment': "%s%s" % (name,  str(uuid.uuid4().hex))
                }
                )
    return response['CloudFrontOriginAccessIdentity']['Id']


def preparelogdestion(region, get_configjson, jazz_stackprefix, secId):
    retRes = {}
    primary_account = get_configjson['data']['config']['AWS']["ACCOUNTS"][0]['ACCOUNTID']
    for stage in ["prod", "dev", "stg"]:
        dest_arn, dest_name = preparedestarn(region, primary_account, jazz_stackprefix, stage)
        putDestinationPolicy(dest_name, dest_arn, secId, region)
        retRes[stage.upper()] = dest_arn
    return retRes


def preparedestarn(region, account, stackprefix, stage):

    return "arn:aws:logs:%s:%s:destination:%s-%s-%s-kinesis" % (region,
                                                                account,
                                                                stackprefix,
                                                                stage, region),\
            "%s-%s-%s-kinesis" % (stackprefix, stage, region)


def updatePrimaryRole(roleArn, stackprefix, account_id):
    permission_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": "sts:AssumeRole",
                "Resource": roleArn
            }
        ]
    }
    # Get the default profile
    session = boto3.Session(profile_name='default')
    # Create IAM client
    iamClient = session.client('iam')
    iamClient.put_role_policy(
        RoleName='%s_platform_services' % (stackprefix),
        PolicyName='%s_%s_NonPrimaryAssumePolicy' % (stackprefix, account_id),
        PolicyDocument=json.dumps(permission_policy)
    )


def putDestinationPolicy(destinatioName, destinatioArn, secId, region):
    # Get the default profile
    session = boto3.Session(profile_name='default')
    logsClient = session.client('logs', region_name=region)
    listAccount = prepare_destination_policy(logsClient, secId, destinatioName)
    access_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "AWS": listAccount
              },
              "Action": "logs:PutSubscriptionFilter",
              "Resource": destinatioArn
            }
        ]
        }
    logsClient.put_destination_policy(
        destinationName=destinatioName,
        accessPolicy=json.dumps(access_policy)
    )


def prepare_destination_policy(client, secId, destinatioName):
    retlist = [secId]
    response = client.describe_destinations(
        DestinationNamePrefix=destinatioName,
    )
    resp = response['destinations'][0]
    if 'accessPolicy' in resp:
        accessPolicy = json.loads(resp['accessPolicy'])
        awsList = accessPolicy["Statement"][0]["Principal"]["AWS"]
        if isinstance(awsList, list):
            if secId not in awsList:
                awsList.append(secId)
            retlist = awsList
    return retlist
