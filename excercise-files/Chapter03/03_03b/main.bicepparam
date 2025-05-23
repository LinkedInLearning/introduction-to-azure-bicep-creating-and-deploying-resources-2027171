using './main.bicep'

param storageName = 'bicepstgtestnew0528'
param azureRegion = 'westus2'
param environment = 'dev'
param aspName = 'newbicep-ch3-02-asp01'
param webAppName = 'newbicep-web-ch3-02-app01'
param acrName = 'demobicepacrnew0528'
param acrSKU = 'Basic'
param enableAdminUser = false
