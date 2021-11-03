# Deploy Azure Container Apps with Bicep

This repository shows how to deploy Azure Container Apps with Bicep. For further guidance check [https://www.thorsten-hans.com/how-to-deploy-azure-container-apps-with-bicep/](https://www.thorsten-hans.com/how-to-deploy-azure-container-apps-with-bicep/).

## Deployment

First, create necessary services

- Azure Resource Group
- Azure Container Registry

For example, you can use Azure CLI to get those up and running:

```bash
acrName="blogsample"
location="northeurope"
# Create Resource Group
az group create -n rg-blog-sample -l $location

# Create Azure Container Registry (ACR)
az acr create -n $acrName -g rg-blog-sample -l $location --sku Basic --admin-enabled true
```

## Publish the sample Container to ACR

```bash
# Login to ACR
az acr login -n $acrName

# Build the container image
./scripts/build-container-image.sh $acrName

# Push the container image
./scripts/push-container-image.sh $acrName
```

## Grab ACR credentials

```bash
acrPassword=$(az acr credential show -n $acrName --query "passwords[0].value" -o tsv)
```

## Create Deployment

```bash
az deployment group create -n container-app \
  -g rg-blog-sample \
  --template-file ./main.bicep \
  -p containerImage=$acrName.azurecr.io/api:0.0.1 \
     containerPort=5000 \
     registry=$acrName.azurecr.io \
     registryUsername=$acrName
```

## Query FQDN

```bash
fqdn=$(az deployment group show -g rg-blog-sample --query properties.outputs.fqdn.value -n container-app -o tsv)
```

## Test an API endpoint

```bash
# test a public API endpoint
curl --silent https://$fqdn/weatherforecast | jq 
```
