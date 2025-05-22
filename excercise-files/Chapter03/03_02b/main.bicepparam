using './main.bicep'

param storageName = 'bicepstgtestwss0522'
param azureRegion = 'westus2'
param environment = 'dev'
param aspName = 'newbicep-ch3-asp01'
param webAppName = 'newbicep-web-ch3-app01'
param acrName = 'demobicepacrw220522'
param acrSKU = 'Basic'
param enableAdminUser = false
