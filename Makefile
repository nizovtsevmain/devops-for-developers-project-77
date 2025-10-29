init:
	terraform -chdir=./terraform/ init -backend-config=secrets.backend.tfvars

tr-apply:
	terraform -chdir=./terraform/ apply

tr-destroy:
	terraform -chdir=./terraform/ destroy