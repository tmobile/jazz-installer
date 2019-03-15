import boto3
from installer.helpers.destroy.delete_event_source_mapping import delete_event_source_mapping
from installer.helpers.destroy.delete_platform_services import delete_platform_services
from installer.helpers.destroy.delete_cf_dists import delete_cf_dists


def destroyprep(stackname, identity, all=False):
    # Delete the identity policy  - Created in terraform/scripts/ses.sh
    client = boto3.client('ses')
    client.delete_identity_policy(
        Identity='string',
        PolicyName="Policy-{0}".format(stackname)
    )

    print("Destroy all: {0} for stack {1}".format(all, stackname))
    # run python scripts to teardown
    if all:
        delete_event_source_mapping(stackname)
        delete_platform_services(stackname, True)
        delete_cf_dists(stackname, True)
    else:
        delete_event_source_mapping(stackname)
        delete_platform_services(stackname, False)
