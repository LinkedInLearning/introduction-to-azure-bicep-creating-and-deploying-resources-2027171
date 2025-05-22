// storageAccount.bicep

param stgAccountName string
param azureRegion string
param skuName string

@description('Experimental storage account resources')
resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgAccountName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
}

output storageId string = bicepStorage.id
output blobEndPoint string = bicepStorage.properties.primaryEndpoints.blob
