from __future__ import print_function
import json
import sys
import decimal
import boto3


tablename = sys.argv[1]
confighashkey = sys.argv[2]
envprefix = sys.argv[3]
installervarsparth = sys.argv[4]
region = sys.argv[5]
account_id = sys.argv[6]
platform_role = sys.argv[7]
user_role = sys.argv[8]
api_dev = sys.argv[9]
api_prod = sys.argv[10]
api_stg = sys.argv[11]
bucket_dev = sys.argv[12]
bucket_prod = sys.argv[13]
bucket_stg = sys.argv[14]
oai = sys.argv[15]
securitygroups = sys.argv[16]
subnets = sys.argv[17]

dynamodb = boto3.resource('dynamodb', region_name=region)
accountname = boto3.client('iam').list_account_aliases()['AccountAliases'][0]
table = dynamodb.Table(tablename)

with open(installervarsparth) as json_file:
    config = json.load(json_file, parse_float=decimal.Decimal)
    config['SCM'] = {key: value for key, value in config['SCM'].items() if value}
    # Store the primary account related information in AWS.ACCOUNTS list as primary
    config['AWS']['ACCOUNTS'] = [{
            "ACCOUNTID": account_id,
            "ACCOUNTNAME": accountname,
            "PRIMARY": True,
            "CREDENTIAL_ID": "jazz_awscreds",
            "IAM": {
              "PLATFORMSERVICES_ROLEID": platform_role,
              "USERSERVICES_ROLEID": user_role
            },
            "CLOUDFRONT": {
              "CLOUDFRONT_ORIGIN_ID": oai
            },
            "REGIONS": [
              {
                "API_GATEWAY": {
                  "DEV": {
                    "*": api_dev
                  },
                  "PROD": {
                      "*": api_prod,
                      "jazz_*": api_prod
                  },
                  "STG": {
                      "*": api_stg,
                      "jazz_*": api_stg
                  }
                },
                "LOGS": {
                  "DEV": "arn:aws:logs:%s:%s:destination:%s-dev-%s-kinesis" % (region, account_id, envprefix, region),
                  "PROD": "arn:aws:logs:%s:%s:destination:%s-prod-%s-kinesis" % (region, account_id, envprefix, region),
                  "STG": "arn:aws:logs:%s:%s:destination:%s-stg-%s-kinesis" % (region, account_id, envprefix, region)
                },
                "REGION": region,
                "PRIMARY": True,
                "S3": {
                  "DEV": bucket_dev,
                  "PROD": bucket_prod,
                  "STG": bucket_stg
                },
                "SECURITY_GROUP_IDS": securitygroups,
                "SUBNET_IDS": subnets
              }
            ]
    }]
    table.put_item(
        Item={
            confighashkey: envprefix,
            'AWS_CREDENTIAL_ID': config['AWS_CREDENTIAL_ID'],
            'AWS': json.loads(json.dumps(config['AWS'])),
            'REPOSITORY': config['REPOSITORY'],
            'JAZZ': config['JAZZ'],
            'JENKINS': config['JENKINS'],
            'SCM': config['SCM'],
            'UI_CONFIG': config['UI_CONFIG'],
            'CODE_QUALITY': config['CODE_QUALITY'],
            'SLACK': config['SLACK'],
            'SPLUNK': config['SPLUNK'],
            'APIGEE': config['APIGEE'],
            'ACL': config['ACL'],
            'AZURE': config['AZURE']
            }
    )
