import argparse
import sys
import requests
import json

parser = argparse.ArgumentParser(
    description='Adds an AWS account to Conformity.')
parser.add_argument('--region', type=str, required=True, choices=[
                    'eu-west-1', 'ap-southeast-2', 'us-west-2'], help='Conformity Service Region')
parser.add_argument('--apiKey', type=str, required=True,
                    help='Conformity API Key')
parser.add_argument('--subscriptionId', type=str,
                    required=True, help='Azure Subscription Id')
parser.add_argument('--directoryId', type=str, required=True,
                    help='Azure Active Directory Id')
parser.add_argument('--accountName', type=str,
                    required=True, help='Account Name')
parser.add_argument('--environment', type=str,
                    required=True, help='Environment')
args = parser.parse_args()

header = {
    "Content-Type": "application/vnd.api+json",
    "Authorization": "ApiKey {}".format(args.apiKey)
}

payload = {
    "data": {
        "type": "account",
        "attributes": {
            "name": "{}".format(args.accountName),
            "environment": "{}".format(args.environment),
            "access": {
                    "subscriptionId": "{}".format(args.subscriptionId),
                    "activeDirectoryId": "{}".format(args.directoryId)
            },
            "costPackage": False
        }
    }
}

conformityEndpoint = "https://{}-api.cloudconformity.com/v1/accounts/azure".format(
    args.region)

response = requests.post(url=conformityEndpoint, json=payload, headers=header)

print(response.text)
