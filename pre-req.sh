resourcePrefix="sohaibazed"
aroClusterServicePrincipalDisplayName="${resourcePrefix}-aro-sp"

# Name and location of the resource group for the Azure Red Hat OpenShift (ARO) cluster
aroResourceGroupName="${resourcePrefix}RG"
location="eastus"

# Subscription id, subscription name, and tenant id of the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# Register the necessary resource providers
az provider register --namespace 'Microsoft.RedHatOpenShift' --wait
az provider register --namespace 'Microsoft.Compute' --wait
az provider register --namespace 'Microsoft.Storage' --wait
az provider register --namespace 'Microsoft.Authorization' --wait

#Create Resource Group
echo "Creating Azure Resource Group"
az group create --name $aroResourceGroupName --location $location 1>/dev/null

# Create the service principal for the Azure Red Hat OpenShift (ARO) cluster
echo "Creating service principal with [$aroClusterServicePrincipalDisplayName] display name in the [$tenantId] tenant..."
az ad sp create-for-rbac --name $aroClusterServicePrincipalDisplayName >app-service-principal.json

aroClusterServicePrincipalClientId=$(jq -r '.appId' app-service-principal.json)
aroClusterServicePrincipalClientSecret=$(jq -r '.password' app-service-principal.json)
aroClusterServicePrincipalObjectId=$(az ad sp show --id $aroClusterServicePrincipalClientId | jq -r '.id')

echo "Assigning User Access Administrator role to Service Principal"
roleName='User Access Administrator'
az role assignment create \
  --role "$roleName" \
  --assignee-object-id $aroClusterServicePrincipalObjectId \
  --resource-group $aroResourceGroupName \
  --assignee-principal-type 'ServicePrincipal' >/dev/null

echo "Assigning Contributor role to Service Principal"
roleName='Contributor'
az role assignment create \
  --role "$roleName" \
  --assignee-object-id $aroClusterServicePrincipalObjectId \
  --resource-group $aroResourceGroupName \
  --assignee-principal-type 'ServicePrincipal' >/dev/null


aroResourceProviderServicePrincipalObjectId=$(az ad sp list --display-name "Azure Red Hat OpenShift RP" --query [0].id -o tsv)

echo "aroClusterServicePrincipalClientId= "$aroClusterServicePrincipalClientId
echo "aroClusterServicePrincipalClientSecret="$aroClusterServicePrincipalClientSecret
echo "aroClusterServicePrincipalObjectId="$aroClusterServicePrincipalObjectId
echo "aroResourceProviderServicePrincipalObjectId"$aroResourceProviderServicePrincipalObjectId
