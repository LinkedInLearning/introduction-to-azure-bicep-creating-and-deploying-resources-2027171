resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'asp-myDemoApp'
  location: resourceGroup().location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webAppResource 'Microsoft.Web/sites@2021-01-15' = {
  name: 'webapp-myDemoApp'
  location: resourceGroup().location
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource mySimpleStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'mydemowebstorage321'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
