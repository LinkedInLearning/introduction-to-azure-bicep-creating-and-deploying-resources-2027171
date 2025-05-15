// storage-parametrized.bicep
param storageName string
param azureRegion string = 'eastus2'
param storageSKU string = 'Standard_LRS'

resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: storageSKU
  }
}
