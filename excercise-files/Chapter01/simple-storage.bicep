// simple-storage.bicep

resource azurebicepstorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'firstbicepstg21'
  location: 'eastus2'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  tags: {
    Environment: 'Demo'
    Project: 'First Look into Azure Bicep'
  }
}
