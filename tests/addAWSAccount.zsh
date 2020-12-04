# create an account

email="$1"
accountName="$2"
roleName="$3"

aws organizations create-account --email ${email} --account-name "${accountName}" --role-name ${roleName}