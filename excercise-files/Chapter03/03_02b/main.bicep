// main.bicep

@minLength(3)
@maxLength(20)
param storageName string

@description('Azure regional location where resource will be deployed')
param azureRegion string

@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Storage SKU defined based on environment type')
var skuName = environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

var stgAccountName = '${storageName}${environment}'

param aspName string
param webAppName string
param acrName string

@allowed(['Basic', 'Standard'])
param acrSKU string

param enableAdminUser bool

module storageService 'storageAccount.bicep' = {
  name: 'storage-module-deployment'
  params: {
    azureRegion: azureRegion
    skuName: skuName
    stgAccountName: stgAccountName
  }
}

module appServiceResource 'appService.bicep' = {
  name: 'app-services-deployment'
  params: {
    aspName: aspName
    azureRegion: azureRegion
    webAppName: webAppName
  }
}

module acrResource 'container-registry.bicep' = {
  name: 'container-registry-service-deployment'
  params: {
    acrName: acrName
    acrSKU: acrSKU
    azureRegion: azureRegion
    enableAdminUser: enableAdminUser
  }
}

output storageId string = storageService.outputs.storageId
output blobEndPoint string = storageService.outputs.blobEndPoint

output webAppHostName string = appServiceResource.outputs.webAppHostName

output acrLoginURL string = acrResource.outputs.acrLoginServer
