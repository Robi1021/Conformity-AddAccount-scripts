import AWS = require('aws-sdk');
import https = require('https');

enum ConformitySubscription {
    ADVANCED = "advanced",
    ESSENTIALS = "essentials"
  }

export const handler = async function (event: any, context: any) {

    console.info('Received this event', JSON.stringify(event));
    console.info('Received this context', JSON.stringify(context));

    const accountName = 'test Account';
    const roleArn = '';

    const addAccount = new Promise((resolve, reject) => {

        const config = {
            hostname: process.env.ConformityAPIHost,
            port: 443,
            path: '/v1/accounts',
            method: 'POST',
            headers: {
                'Content-Type': 'application/vnd.api+json',
                'Authorization': 'ApiKey ' + process.env.ConformityAPIKey
            }
        };

        const payload = {
            'data': {
                'type': 'account',
                'attributes': {
                    'name': accountName,
                    'environment': '',
                    'access': {
                        'keys': {
                            'roleArn': roleArn,
                            'externalId': process.env.ConformityExternalId
                        }
                    },
                    'costPackage': false,
                    'subscriptionType': process.env.SubscriptionType
                }
            }
        };

        var request = https.request(config, function (resolve: any) {
            var response = '';

            request.on('data', function (chunk: any) {
                return response += chunk;
            });

            request.on('end', function () {
                console.info('Account Added', JSON.stringify(response));
                resolve({
                    statusCode: resolve.statusCode,
                    body: JSON.stringify('response')
                });
            });
        });

        request.on('error', function (error: any) {
            console.error('Error while adding the account', JSON.stringify(error));
            reject({
                statusCode: error.statusCode,
                body: JSON.stringify(error)
            });
        });

        request.write(payload);
        request.end();
    });

    return addAccount;
}