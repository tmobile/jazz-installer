import boto3
import sys
import time


def health_check_tg(client, tg_arn, max_tries):
    if max_tries == 1:
        return False
    else:
        max_tries -= 1
    try:
        response = client.describe_target_health(TargetGroupArn=str(tg_arn))
        if response['TargetHealthDescriptions'][0]['TargetHealth']['State'] == 'healthy':
            time.sleep(30)
            return True
        else:
            time.sleep(30)
            health_check_tg(client, tg_arn, max_tries)
    except Exception:
        time.sleep(30)
        health_check_tg(client, tg_arn, max_tries)


if __name__ == u"__main__":
    client = boto3.client('elbv2')
    health_check_tg(client, sys.argv[1], 50)
