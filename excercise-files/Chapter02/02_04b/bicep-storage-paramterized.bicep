// bicep-storage-parametrized.bicep

param storageName string = 'stparamdemo0521'
param azureRegion string = 'westus2'
param stgSKU string = 'Standard_LRS'

resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: stgSKU
  }
}
