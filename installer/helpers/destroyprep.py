import boto3
from installer.helpers.destroy.delete_event_source_mapping import delete_event_source_mapping
from installer.helpers.destroy.delete_platform_services import delete_platform_services
from installer.helpers.destroy.delete_cf_dists import delete_cf_dists


def destroyprep(stackname, identity, region, all=False):
    # Delete the identity policy  - Created in terraform/scripts/ses.sh
    client = boto3.client('ses', region_name=region)
    cloudfront_client = boto3.client('cloudfront', region_name=region)
    lambda_client = boto3.client('lambda', region_name=region)
    cloudformation_client = boto3.client('cloudformation', region_name=region)
    client.delete_identity_policy(
        Identity=identity,
        PolicyName="Policy-{0}".format(stackname)
    )

    print("Destroy all: {0} for stack {1}".format(all, stackname))
    # run python scripts to teardown
    if all:
        delete_event_source_mapping(stackname, lambda_client)
        delete_platform_services(stackname, cloudformation_client, True)
        delete_cf_dists(stackname, cloudfront_client, True)
    else:
        delete_event_source_mapping(stackname, lambda_client)
        delete_platform_services(stackname, cloudformation_client, False)
