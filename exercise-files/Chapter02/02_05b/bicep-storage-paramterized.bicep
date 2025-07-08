// bicep-storage-parametrized.bicep

param storageName string
param azureRegion string
param stgSKU string

resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: stgSKU
  }
}
