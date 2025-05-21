// storage-parametrized.bicep

@minLength(3)
@maxLength(20)
param storageName string

@description('Azure regional location where resource will be deployed')
param azureRegion string

@maxLength(14)
@allowed(['Standard_LRS', 'Standard_GRS'])
param storageSKU string

@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Storage SKU defined based on environment type')
var skuName = environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

// Experimental storage account resources
@description('Experimental storage account resources')
resource bicepStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${storageName}${environment}'
  location: azureRegion
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
}
