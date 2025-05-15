// multi-deployment.bicep

targetScope = 'subscription'

// Step 4: Let's parametrize teh deployment location
param azureRegion string = 'eastus2'

resource myResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-application-rg'
  location: azureRegion
  tags: {
    Environment: 'Demo'
    Project: 'Bicep Demo'
  }
}

module appService 'simple-webapp.bicep' = {
  scope: resourceGroup(myResourceGroup.name)
  name: 'webAppDeployment-${uniqueString(myResourceGroup.id)}'
  params: {
    azureRegion: myResourceGroup.location
  }
}

// Step 6: Provision a separate resource group for storage services
resource myStorageResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'bicep-storage-rg'
  location: azureRegion
  tags: {
    Environment: 'Demo'
    Project: 'Bicep Demo'
  }
}

// Step 2: Let's reuse the container registry Bicep code from Chapter 3
module containerRegistry '../03_02b/conatainer-registry.bicep' = {
  scope: resourceGroup(myStorageResourceGroup.name)
  name: 'containerRegistryDeployment-${uniqueString(myStorageResourceGroup.id)}'
  params: {
    containerRegistryName: 'demoacrbicep0518'
  }
}

// Step 3: Let's re-use the code by bringing a storage service with variables code from Chapter2 02_06e
module storageWithVariables '../../Chapter02/02_06e/storage-w-variables.bicep' = {
  scope: resourceGroup(myStorageResourceGroup.name)
  name: 'storageDeployment-${uniqueString(myStorageResourceGroup.id)}'
  params: {
    azureRegion: myStorageResourceGroup.location
    storageName: 'demostgbicep0518'
  }
}

// Step 5: Review expected deployment resources via Bicep Visualizer

// Step 6: Move webApp and storage resources into separate resource groups
