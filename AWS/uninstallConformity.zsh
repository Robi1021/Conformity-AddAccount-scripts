# removes Conformity off the AWS accounts

# stop if an error occurs
set -e

awsOrganizationOuId="$1"

aws cloudformation delete-stack-instances --cli-input-yaml file://ConformityConformity.delete-stackset-instance.yaml --deployment-targets OrganizationalUnitIds=${awsOrganizationOuId}

aws cloudformation delete-stack-set --stack-set-name 'CloudConformityMonitoring_StackSet'