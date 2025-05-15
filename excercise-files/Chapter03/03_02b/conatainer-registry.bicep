// conatainer-registry.bicep

targetScope = 'resourceGroup'

param containerRegistryName string = 'demoacrbidep0515'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: containerRegistryName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Show the login URL
output loginServer string = containerRegistry.properties.loginServer
