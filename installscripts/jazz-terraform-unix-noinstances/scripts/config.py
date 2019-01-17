from __future__ import print_function
import json
import sys
import decimal
import boto3

dynamodb = boto3.resource('dynamodb', region_name=sys.argv[5])

table = dynamodb.Table(sys.argv[1])

with open(sys.argv[4]) as json_file:
    config = json.load(json_file, parse_float=decimal.Decimal)
    print("Adding Jazz config:")
    table.put_item(
        Item={
            sys.argv[2]: sys.argv[3],
            'AWS_CREDENTIAL_ID': config['AWS_CREDENTIAL_ID'],
            'AWS': config['AWS'],
            'REPOSITORY': config['REPOSITORY'],
            'JAZZ': config['JAZZ'],
            'JENKINS': config['JENKINS'],
            'SCM': config['SCM'],
            'UI_CONFIG': config['UI_CONFIG'],
            'CODE_QUALITY': config['CODE_QUALITY'],
            'SLACK': config['SLACK'],
            'SPLUNK': config['SPLUNK']
            }
    )
