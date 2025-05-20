param azureRegion string = resourceGroup().location

// Parametrize the app and site names
param appServicePlanName string = 'asp-myDemoApp-0515'
param webAppResourceName string = 'webapp-myDemoApp-0515'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: azureRegion
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webAppResource 'Microsoft.Web/sites@2021-01-15' = {
  name: webAppResourceName
  location: azureRegion
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output webAppResourceHostName string = webAppResource.properties.defaultHostName
