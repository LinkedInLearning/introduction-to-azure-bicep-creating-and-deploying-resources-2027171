param azureRegion string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'asp-myDemoApp'
  location: azureRegion
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webAppResource 'Microsoft.Web/sites@2021-01-15' = {
  name: 'webapp-myDemoApp'
  location: azureRegion
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output webAppResourceHostName string = webAppResource.properties.defaultHostName
