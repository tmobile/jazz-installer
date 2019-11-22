import boto3
import sys
import time


def cleanup(client, vpc_id, sg_id):
    in_use_found = False
    try:
        response = client.describe_network_interfaces(
            Filters=[
                {
                    'Name': 'vpc-id',
                    'Values': [
                        str(vpc_id),
                    ]
                },
                {
                    'Name': 'group-id',
                    'Values': [
                        str(sg_id),
                    ]
                },
            ],
        )
        for item in response['NetworkInterfaces']:
            if "AWS Lambda VPC ENI" in item['Description']:
                if item['Status'] == 'in-use':
                    in_use_found = True
                if item['Status'] == 'available':
                    # delete the ENI
                    print("Item to delete: " + str(item['NetworkInterfaceId']))
                    response = client.delete_network_interface(
                         NetworkInterfaceId=str(item['NetworkInterfaceId'])
                    )
        if in_use_found:
            print("Still In use ENIs found")
            time.sleep(30)
            cleanup(client, vpc_id, sg_id)
        else:
            return True
    except Exception as message:
        print(message)
        time.sleep(30)
        cleanup(client, vpc_id, sg_id)


if __name__ == u"__main__":
    client = boto3.client('ec2')
    cleanup(client, sys.argv[1], sys.argv[2])
