apply:
	terraform -chdir=./terraform/ apply -var-file=secrets.tfvars