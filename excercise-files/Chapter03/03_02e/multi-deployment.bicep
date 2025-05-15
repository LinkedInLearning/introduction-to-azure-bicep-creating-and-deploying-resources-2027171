// multi-deployment.bicep

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-application-rg'
  location: 'eastus2'
  tags: {
    Environment: 'Demo'
    Project: 'Bicep Demo'
  }
}
