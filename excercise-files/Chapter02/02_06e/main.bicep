// main.bicep

@minLength(3)
@maxLength(20)
param storageName string

@description('Azure regional location where resource will be deployed')
param azureRegion string

@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Storage SKU defined based on environment type')
var skuName = environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

var stgAccountName = '${storageName}${environment}'

param aspName string // 'mybicep-asp01'
param webAppName string // 'mybicep-web-app01'

// Experimental storage account resources
@description('Experimental storage account resources')
resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgAccountName
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
}

// Add App Service Plan and Web App
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: aspName
  location: azureRegion
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: webAppName
  location: azureRegion
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output storageId string = bicepStorage.id
output blobEndPoint string = bicepStorage.properties.primaryEndpoints.blob
output webAppHostName string = webApplication.properties.defaultHostName
