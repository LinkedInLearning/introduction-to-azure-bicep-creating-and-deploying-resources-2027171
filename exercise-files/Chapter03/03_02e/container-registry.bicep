// container-registry.bicep

targetScope = 'resourceGroup'

param acrName string = 'demoacrbicep0515'
param azureRegion string = resourceGroup().location
param acrSKU string = 'Basic'
param enableAdminUser bool = false

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: azureRegion
  sku: {
    name: acrSKU
  }
  properties: {
    adminUserEnabled: enableAdminUser
  }
}

// Shows the Adminlogin URL
output acrLoginServer string = containerRegistry.properties.loginServer
