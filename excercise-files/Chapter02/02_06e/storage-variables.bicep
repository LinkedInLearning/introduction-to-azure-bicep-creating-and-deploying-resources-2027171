// storage-variables.bicep
// This is example of using variables and outputs.

param storageName string
param azureRegion string
param environment string

var accountName = '${storageName}${environment}'
var storageAccountSkuName = (environment == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

// Note: about the resource API version
resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: accountName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
}

// Step 2: Add res-app-plan & res-app-web 
// Step 3: Add output Host URL

output storageId string = bicepStorage.id
output blobEndpoint string = bicepStorage.properties.primaryEndpoints.blob
