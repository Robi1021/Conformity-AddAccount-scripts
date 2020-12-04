# installs Conformity on the AWS accounts and makes it a guardrail (added automatically for all accounts)

# stop if an error occurs
set -e

ConformityRTMAccountId="$1"
awsOrganizationOuId="$2"

aws cloudformation create-stack-set --cli-input-yaml file://CloudConformityRTM.stackset.yaml --parameters ParameterKey=ConformityRTMAccountId,ParameterValue=${ConformityRTMAccountId}

aws cloudformation create-stack-instances --cli-input-yaml file://CloudConformityRTM.stacksetinstance.yaml --deployment-targets OrganizationalUnitIds=${awsOrganizationOuId}