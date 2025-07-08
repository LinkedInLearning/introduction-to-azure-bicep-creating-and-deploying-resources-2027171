// simple-storage.bicep

param stgAccountName string
param azureRegion string

@allowed(['Standard_LRS', 'Standard_GRS'])
param storageSKU string

resource firstbicepstg123 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgAccountName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: storageSKU
  }
  tags: {
    Environment: 'Demo'
    Project: 'Intro to Azure Bicep'
  }
}
