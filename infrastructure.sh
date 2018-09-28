#!/bin/bash

# from bash, do: chmod +x infrastructure.sh

ACR_NAME="lugiziaciplaygroundacr"
RES_GROUP=$ACR_NAME-rg # Resource Group name

#rg="lugizi-aci-playground-rg"
#st="aciplaygroundst"
loc="westus2"

az group delete -n $RES_GROUP -y

az group create --resource-group $RES_GROUP -l $loc

az acr build --registry $ACR_NAME --os Windows --image aciplaygroundacrtasks:v1 ./src

#az storage account create -n aciplaygroundst -g $rg -l westus2 --sku Standard_LRS

az acr create -n $ACR_NAME -g $RES_GROUP -l $loc --sku Standard

az acr task create \
    --registry $ACR_NAME \
    --name taskworkerrole \
    --image workerrole:{{.Run.ID}} \
    --context https://github.com/luisgmsft/aci-playground-role.git \
    --branch master \
    --file src/dockerfile \
    --git-access-token $(az keyvault secret show --vault-name $AKV_NAME --name $ACR_NAME-git-pat --query value -o tsv)


# az functionapp create --resource-group $rg --consumption-plan-location $loc --name aciplaygroundfa --storage-account $st

AKV_NAME=$ACR_NAME-vault

az keyvault create --resource-group $RES_GROUP --name $AKV_NAME
az keyvault secret set \
  --vault-name $AKV_NAME \
  --name $ACR_NAME-pull-pwd \
  --value $(az ad sp create-for-rbac \
                --name $ACR_NAME-pull \
                --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
                --role reader \
                --query password \
                --output tsv)

# Store service principal ID in AKV (the registry *username*)
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-pull-usr \
    --value $(az ad sp show --id http://$ACR_NAME-pull --query appId --output tsv)

az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-git-pat \
    --value [gh-obtained-pat]

az container create \
    --resource-group $RES_GROUP \
    --os Windows \
    --name acr-tasks \
    --image $ACR_NAME.azurecr.io/aciplaygroundroletasks:v2 \
    --registry-login-server $ACR_NAME.azurecr.io \
    --registry-username $(az keyvault secret show --vault-name $AKV_NAME --name $ACR_NAME-pull-usr --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name $AKV_NAME --name $ACR_NAME-pull-pwd --query value -o tsv) \
    --restart-policy Never \
    --command-line "Console.Worker.Role.exe 11111" \
    -e key1=value1 key2=value2