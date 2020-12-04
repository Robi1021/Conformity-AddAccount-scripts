# removes Conformity off the AWS accounts

# stop if an error occurs
set -e

awsOrganizationOuId="$1"

aws cloudformation delete-stack-instances --cli-input-yaml file://CloudConformityRTM.delete-stackset-instance.yaml --deployment-targets OrganizationalUnitIds=${awsOrganizationOuId} --no-retain-stacks

aws cloudformation delete-stack-set --stack-set-name 'CloudConformityRTMStackSet'