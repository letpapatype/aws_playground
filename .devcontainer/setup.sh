hcp auth login --client-id=$VAULT_CLIENT_ID --client-secret=$VAULT_CLIENT_SECRET
hcp profile init --vault-secrets
export AWS_ACCESS_KEY_ID=$(hcp vault-secrets secrets open aws_access_key --format json | jq -r '.static_version.value')
export AWS_SECRET_ACCESS_KEY=$(hcp vault-secrets secrets open aws_secret_access_key --format json | jq -r '.static_version.value')

export TF_VAR_vault_client_id=$VAULT_CLIENT_ID
export TF_VAR_vault_client_secret=$VAULT_CLIENT_SECRET