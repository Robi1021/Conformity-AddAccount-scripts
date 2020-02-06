# Adds an AWS Account to Cloud Conformity with the following charasterictics:
#   Name: $AccountName
#   Environment: $Environment
#   Cost Optimisation: Enabled by default
#   Real-time monitoring: Enabled and configured by default
#   Cloud Conformity Endpoint: Endpoint for the given $CCEndpointRegion
#
# Requirements: 
#   CC API Secret ($CCAPIKey)
#   AWS CLI configured with a named profile including a default region ($AWSNamedProfile)
#   Access to AWS services as described at https://cloudconformity.atlassian.net/wiki/spaces/HELP/pages/66256941/Real-Time+Threat+Monitoring+settings

# stop if an error occurs
set -e

# allow to throw exceptions
#autoload throw catch

# CC API Secret which can be obtained from the Administration menu
CCAPIKey="$1"
# CC Endpoint Region: Choice of eu-west-1, ap-southeast-2 or us-west-2
CCEndpointRegion="$2"
# AWS CLI named profile
AWSNamedProfile="$3"
# Name and environment to be used in CC to identify the account
AccountName="$4"
Environment="$5"

# initial set up
StackId=""
StackStatus=""
AWSAccountId=""
CCAccountId=""
CCOrganisationId=""
ExternalId=""
ARN=""
payload=""
response=""

echo "Adding the AWS account ${AccountName} - ${Environment} environment to Cloud Conformity (${CCEndpointRegion}) using the AWS CLI named profile ${AWSNamedProfile}."
echo "See https://github.com/cloudconformity/documentation-api/blob/master/Accounts.md for additional details."

# Get the External ID. See https://github.com/cloudconformity/documentation-api/blob/master/ExternalId.md#get-organisation-external-id
echo "Getting your organization's Cloud Conformity ExternalId."
response=$(curl -s -X GET -H "Content-Type: application/vnd.api+json" -H "Authorization: ApiKey ${CCAPIKey}" https://${CCEndpointRegion}-api.cloudconformity.com/v1/organisation/external-id)
ExternalId=$(jq -r '.data.id?' <<<"${response}")
echo "Your Organization's External ID is ${ExternalId}."

# configure the AWS CLI
export AWS_PROFILE=${AWSNamedProfile}

# Configure the account - Option2. See https://github.com/cloudconformity/documentation-api/blob/master/Accounts.md#create-an-account
echo "Creating the Cloud Conformity stack."
response=$(aws cloudformation create-stack --stack-name CloudConformity --template-url https://s3-us-west-2.amazonaws.com/cloudconformity/CloudConformity.template --parameters ParameterKey=AccountId,ParameterValue=717210094962 ParameterKey=ExternalId,ParameterValue=${ExternalId} --capabilities CAPABILITY_NAMED_IAM)
StackId=$(jq -r '.StackId' <<<"${response}")

# wait until the CloudConformity cloudformation is provisioned
while [ "$StackStatus" != "CREATE_COMPLETE" ]; do
    # todo: add timeout.sh
    response=$(aws cloudformation describe-stacks --stack-name CloudConformity)

    StackStatus=$(jq -r '.Stacks[0].StackStatus' <<<"${response}")
    echo "Just a moment."
done
echo "The StackID is ${StackId}."
echo "Getting the ARN."
response=$(aws cloudformation describe-stacks --stack-name CloudConformity)
ARN=$(jq -r '.Stacks[0].Outputs[1].OutputValue?' <<<"${response}")
echo "The ARN is ${ARN}."

# Add the account to CC using the external ID and ARN - Step 3
echo "Adding the account to Cloud Conformity."
payload="{\"data\":{\"type\": \"account\",\"attributes\": {\"name\": \"${AccountName}\",\"environment\": \"${Environment}\",\"access\": {\"keys\": {\"roleArn\": \"${ARN}\",\"externalId\": \"${ExternalId}\"}},\"costPackage\": true,\"hasRealTimeMonitoring\": true}}}"
response=$(curl -s -X POST -H "Content-Type: application/vnd.api+json" -H "Authorization: ApiKey ${CCAPIKey}" -d ''${payload}'' https://${CCEndpointRegion}-api.cloudconformity.com/v1/accounts)

AWSAccountId=$(jq -r '.data.attributes["awsaccount-id"]' <<<"${response}")
CCAccountId=$(jq -r '.data.id' <<<"${response}")
CCOrganisationId=$(jq -r '.data.relationships.organisation.data.id' <<<"${response}")

echo "Added AWS Account ${AWSAccountId} under Cloud Conformity Account ID ${CCAccountId}, Organization ID ${CCOrganisationId}."

echo "Enabling real-time monitoring."
# Enable RTM in the account. See https://cloudconformity.atlassian.net/wiki/spaces/HELP/pages/66256941/Real-Time+Threat+Monitoring+settings
TEMPLATE_URL=https://s3-us-west-2.amazonaws.com/cloud-conformity-public-staging-us-west-2/monitoring/event-bus-template.yml
CC_ACCOUNT_ID=105579776292
RTM_REGIONS=( us-east-1 us-east-2 us-west-1 us-west-2 ca-central-1 eu-west-1 eu-central-1 eu-west-2 eu-west-3 eu-north-1 ap-northeast-1 ap-northeast-2 ap-southeast-1 ap-southeast-2 ap-south-1 sa-east-1 ap-east-1 me-south-1 )
CLASSIC_REGIONS=( us-east-1 us-east-2 us-west-1 us-west-2 ca-central-1 eu-west-1 eu-central-1 eu-west-2 eu-west-3 eu-north-1 ap-northeast-1 ap-northeast-2 ap-southeast-1 ap-southeast-2 ap-south-1 sa-east-1 )
STACK_NAME=CloudConformityMonitoring
STACK_VERSION=5

function is_region_enabled()
{
  local region="$1"
  if [[ " ${CLASSIC_REGIONS[*]} " =~ ${region} ]]; then
    return 0
  elif aws sts get-caller-identity --region "$region" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

echo "Installing Cloud Conformity Real-time Monitoring..."
for region in "${RTM_REGIONS[@]}"; do
  if is_region_enabled "$region"; then
    if aws cloudformation describe-stacks --stack-name $STACK_NAME --region "$region" --output json >/dev/null 2>&1; then
      echo "Updating $STACK_NAME - V$STACK_VERSION in $region"
      aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --parameters \
        ParameterKey=CloudConformityAccountId,ParameterValue="$CC_ACCOUNT_ID" \
        --region "$region" \
        --template-url "$TEMPLATE_URL" \
        --capabilities CAPABILITY_IAM \
        --tags \
        Key=Version,Value=$STACK_VERSION Key=LastUpdatedTime,Value="$(date)" &&
        echo "Successfully updated $STACK_NAME in $region."
    else
      echo "Installing $STACK_NAME - V$STACK_VERSION in $region"
      aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --parameters \
        ParameterKey=CloudConformityAccountId,ParameterValue="$CC_ACCOUNT_ID" \
        --region "$region" \
        --template-url "$TEMPLATE_URL" \
        --on-failure DO_NOTHING \
        --capabilities CAPABILITY_IAM \
        --tags \
        Key=Version,Value=$STACK_VERSION Key=LastUpdatedTime,Value="$(date)" &&
        echo "Successfully installed $STACK_NAME in $region."
    fi
  else
    echo "Region $region is either not enabled or not supported with the current access credentials"
  fi
done
echo "Scanning the account."
response=$(curl -s -X POST -H "Content-Type: application/vnd.api+json" -H "Authorization: ApiKey ${CCAPIKey}" https://${CCEndpointRegion}-api.cloudconformity.com/v1/accounts/${CCAccountId}/scan)

echo "The Cloud Conformity bot will continue scanning the AWS Account ${AccountName} - ${Environment} in the background."
echo "At this point you can visit the dashboard to review."