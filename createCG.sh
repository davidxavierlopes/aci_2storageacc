# Create azure storage accounts

RESOURCEGROUP=acirepro
LOCATION=uksouth
STORAGE1=acireprostorage1
STORAGE2=acireprostorage2
SHARENAME1=acireproname1
SHARENAME2=acireproname2

az group create --name $RESOURCEGROUP --location $LOCATION
az storage account create --name $STORAGE1 --resource-group $RESOURCEGROUP --location $LOCATION --sku Standard_LRS --kind StorageV2
az storage account create --name $STORAGE2 --resource-group $RESOURCEGROUP --location $LOCATION --sku Standard_LRS --kind StorageV2

# Create Fileshares on the storage accounts

az storage share create \
  --name $SHARENAME1 \
  --account-name $STORAGE1

az storage share create \
  --name $SHARENAME2 \
  --account-name $STORAGE2

# Get Storage accounts keys

cp containergroup.yaml.ori containergroup.yaml

KEY1=`az storage account keys list --resource-group $RESOURCEGROUP --account-name $STORAGE1 --query "[0].value" --output tsv`
KEY2=`az storage account keys list --resource-group $RESOURCEGROUP --account-name $STORAGE2 --query "[0].value" --output tsv`

# Substitute values on yaml

sed -i "s|CHANGEME1|${KEY1}|g" "containergroup.yaml"
sed -i "s|CHANGEME2|${KEY2}|g" "containergroup.yaml"
sed -i "s|LOCATION|${LOCATION}|g" "containergroup.yaml"
sed -i "s|SHARENAME1|${SHARENAME1}|g" "containergroup.yaml"
sed -i "s|SHARENAME2|${SHARENAME2}|g" "containergroup.yaml"
sed -i "s|STORAGE1|${STORAGE1}|g" "containergroup.yaml"
sed -i "s|STORAGE2|${STORAGE2}|g" "containergroup.yaml"

az container create -g $RESOURCEGROUP --file containergroup.yaml
rm containergroup.yaml
