import argparse, sys, requests, json

parser=argparse.ArgumentParser(description='Adds an AWS account to Conformity.')
parser.add_argument('--region', type=str, required=True, choices=['eu-west-1', 'ap-southeast-2', 'us-west-2'], help='Conformity API Key')
parser.add_argument('--apiKey', type=str, required=True, help='Conformity API Key')
parser.add_argument('--roleArn', type=str, required=True, help='AWS Conformity Role ARN')
parser.add_argument('--externalId', type=str, required=True, help='Conformity External Id')
parser.add_argument('--accountName', type=str, required=True, help='Account Name')
parser.add_argument('--environment', type=str, required=True, help='Environment')
parser.add_argument('--subscriptionType', type=str, required=True, choices=['essentials', 'advanced'], help='essentials or advanced')
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
                "keys": {
                    "roleArn": "{}".format(args.roleArn),
                    "externalId": "{}".format(args.externalId)
                }
            },
            "costPackage": False,
            "subscriptionType": "{}".format(args.subscriptionType.lower())
        }
    }
}

conformityEndpoint = "https://{}-api.cloudconformity.com/v1/accounts".format(args.region)

response = requests.post(url=conformityEndpoint, json=payload, headers=header)

print(response.text)
