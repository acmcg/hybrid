# hybrid
Azure and Azure Stack Hybrid Scenarios

#To build run 
docker build https://github.com/acmcg/hybrid.git -t terraform:windows

#For Azure Cli
az cloud unregister -n AzureStackUser 

**For a multitenancy Azure Stack I tried with:**

C:\>az cloud register -n AzureStackUser --endpoint-resource-manager "https://management.equinix.vigilant.it" --suffix-keyvault-dns ".vaultequinix.vigilant.it" --profile 2018-03-01-hybrid --endpoint-active-directory-resource-id "https://graph.windows.net/" --endpoint-vm-image-alias-doc https://github.com/acmcg/hybrid/blob/master/aliases.json 

C:\>az login
You have logged in. Now let us find all the subscriptions to which you have access...
The access token has been obtained for wrong audience or resource 'https://graph.windows.net/'. It should exactly match with one of the allowed audiences 'https://management.azureinfinitis.onmicrosoft.com/3a33850c-fcea-4740-a8fc-320c93d6a190'.

**Worked once updated**
az cloud register -n AzureStackUser --endpoint-resource-manager "https://management.equinix.vigilant.it" --suffix-keyvault-dns ".vaultequinix.vigilant.it" --profile 2018-03-01-hybrid --endpoint-active-directory-resource-id "https://management.azureinfinitis.onmicrosoft.com/3a33850c-fcea-4740-a8fc-320c93d6a190" --endpoint-vm-image-alias-doc https://github.com/acmcg/hybrid/blob/master/aliases.json 

az cloud set -n AzureStackUser
az cloud update --profile 2018-03-01-hybrid

**Use the following command to get image list**
az vm image list --all
This can be used to update alias file https://github.com/acmcg/hybrid/blob/master/aliases.json 

**Run the following and record**
az ad sp create-for-rbac -n "Packer" --role contributor --scopes /subscriptions/a5bd5d47-8056-47ed-be92-2f53401c709f

packer build -var-file=ubuntuPackerAzsVariables.json ubuntuPacker.json