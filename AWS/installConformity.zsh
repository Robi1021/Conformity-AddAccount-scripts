# installs Conformity on the AWS accounts and makes it a guardrail (added automatically for all accounts)

# stop if an error occurs
set -e

ccAccountId="$1"
externalId="$2"
awsOrganizationOuId="$3"

aws cloudformation create-stack-set --cli-input-yaml file://CloudConformity.stackset.yaml --parameters ParameterKey=AccountId,ParameterValue=${ccAccountId} ParameterKey=ExternalId,ParameterValue=${externalId}

aws cloudformation create-stack-instances --cli-input-yaml file://CloudConformity.stacketinstance.yaml --deployment-targets OrganizationalUnitIds=${awsOrganizationOuId} --regions us-east-1