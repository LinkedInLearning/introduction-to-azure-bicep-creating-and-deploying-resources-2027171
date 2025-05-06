// multi-deployment.bicep

targetScope = 'subscription'

@description('Azure location for all resources')
param azureRegion string = 'eastus'

resource appGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-applications-rg'
  location: azureRegion
  tags: {
    Project: 'Bicep Demo'
  }
}

module appService 'simple-webapp.bicep' = {
  scope: resourceGroup(appGroup.name)
  name: 'webAppDeployment-${uniqueString(appGroup.id)}'
}

resource containerGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-containers-rh'
  location: azureRegion
  tags: {
    'Project': 'Bicep Demo'
  }
}

module containerRegistry 'container-registry.bicep' = {
  scope: resourceGroup(containerGroup.name)
  name: 'acrDeployment-${uniqueString(containerGroup.id)}'
}
