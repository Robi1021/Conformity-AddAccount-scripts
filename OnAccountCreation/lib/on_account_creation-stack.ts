import * as cdk from '@aws-cdk/core';
import * as sns from '@aws-cdk/aws-sns';
import * as lambda from '@aws-cdk/aws-lambda';
import * as iam from '@aws-cdk/aws-iam';
import * as snsInvoker from '@aws-cdk/aws-lambda-event-sources';
import { CfnParameter } from '@aws-cdk/core';
import { Subscription } from '@aws-cdk/aws-sns';

enum ConformitySubscription {
  ADVANCED = "advanced",
  ESSENTIALS = "essentials"
};

export class OnAccountCreationStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // this stack creates a SNS topic, a lambda function and role that together add an aws account to conformity

    // deployment parameters
    const conformityApiHost = new CfnParameter(this, 'conformityAPIHost', {
      type: "String",
      description: 'Conformity API host'
    });

    const conformityApiKey = new CfnParameter(this, 'conformityAPIKey', {
      type: "String",
      description: 'Conformity API Key'
    });

    const conformityExternalId = new CfnParameter(this, 'conformityExternalId', {
      type: "String",
      description: 'Conformity External Id'
    });

    const conformitySubscriptionType = new CfnParameter(this, 'subscriptionType', {
      type: "String",
      description: "Conformity subscription type (Essentials or Advanced)"
    });

    // the sns topic
    const snsTopic = new sns.Topic(this, 'ConformityAddAccountTopic', {
      displayName: 'ConformityAddAccountTopic'
    });

    // the lambda role
    const lambdaRole = new iam.Role(this, 'ConformityAddAccountRole', {
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      roleName: 'ConformityAddAccountRole'
    });

    // Let the function send trace data to x-ray
    lambdaRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('AWSXRayDaemonWriteAccess'));

    // Let the function log events to cloudwatch
    lambdaRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole'));
    
    // the lambda function
    const lambdaFunction = new lambda.Function(this, 'ConformityAddAccount', {
      description: 'Calls Conformity to add an AWS account',
      functionName: 'ConformityAddAccount',
      handler: 'ConformityAddAccount.handler',
      code: lambda.Code.fromAsset('./src'),
      runtime: lambda.Runtime.NODEJS_12_X,
      role: lambdaRole,
      environment: {
        'ConformityAPIHost': conformityApiHost.valueAsString,
        'ConformityAPIKey': conformityApiKey.valueAsString,
        'ConformityExternalId': conformityExternalId.valueAsString,
        'SubscriptionType': (conformitySubscriptionType.valueAsString.toLowerCase() === ConformitySubscription.ESSENTIALS ) ? ConformitySubscription.ESSENTIALS : ConformitySubscription.ADVANCED
      }
    });

    // the sns invoker
    const lambdaInvoker = new snsInvoker.SnsEventSource(snsTopic, {});
    lambdaInvoker.bind(lambdaFunction);
  }
}
