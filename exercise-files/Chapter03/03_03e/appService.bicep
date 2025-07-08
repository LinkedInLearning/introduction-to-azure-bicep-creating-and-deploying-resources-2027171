// appService.bicep

param aspName string
param azureRegion string
param webAppName string

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

output webAppHostName string = webApplication.properties.defaultHostName
