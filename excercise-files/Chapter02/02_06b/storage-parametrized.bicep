// storage-parametrized.bicep

// concat(storageName, 'dev')

param storageName string
param azureRegion string
param storageSKU string
param environment string = 'dev'

resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${storageName}${environment}' // try putting dash in between?
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: storageSKU
  }
}
