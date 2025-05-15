// storage-w-variables.bicep

// This is example of using variables and outputs.

param storageName string
param azureRegion string
param environment string = 'dev'

var accountName = '${storageName}${environment}'
var storageAccountSkuName = (environment == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: accountName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
}
