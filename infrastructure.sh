#!/bin/bash

# from bash, do: chmod +x infrastructure.sh

rg="lugizi-aci-playground-rg"
st="aciplaygroundst"

az group delete -n $rg -y

az group create -n lugizi-aci-playground-rg -l westus2

az storage account create -n aciplaygroundst -g $rg -l westus2 --sku Standard_LRS

az acr create -n aciplaygroundacr -g $rg -l westus2 --sku Basic

az functionapp create --resource-group $rg --consumption-plan-location westus2 --name aciplaygroundfa --storage-account  $st