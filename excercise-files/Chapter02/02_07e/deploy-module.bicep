// deploy-module.bicep

module appService 'simple-webapp.bicep' = {
  name: 'myWebAppBicepDeployment' // Check params on th bicep file, add if missing
  params: {
    azureRegion: resourceGroup().location
  }
}

output appServiceHostName string = appService.outputs.webAppResourceHostName
