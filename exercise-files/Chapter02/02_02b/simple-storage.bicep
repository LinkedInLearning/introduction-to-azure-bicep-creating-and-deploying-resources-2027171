// simple-storage.bicep
// Note: change the name of a storage account to be unique

resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'simplestgey0521'
  location: 'westus2'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
