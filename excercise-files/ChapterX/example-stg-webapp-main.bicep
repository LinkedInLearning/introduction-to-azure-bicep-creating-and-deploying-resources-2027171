// main.bicep

// Parameters allow customization of deployment location and environment
param location string = resourceGroup().location
param environment string = 'dev' // Allowed values could be 'dev', 'test', 'prod'

// Use uniqueString() with the resource group's ID and the environment as seed values
// to generate a unique suffix for names. This ensures that deployments to different
// resource groups or in different environments do not clash.
var uniqueSuffix = uniqueString(resourceGroup().id, environment)

// To adhere to naming conventions (and account for character limits),
// shorten the generated suffix using substring(). Note that storage account names
// must be lowercase and between 3 and 24 characters.
var webSuffix = substring(uniqueSuffix, 0, 8)
var storageSuffix = substring(uniqueSuffix, 0, 10)

// Construct resource names. We use toLower() to guarantee that names
// like the storage account name are all lowercase.
var webAppName = toLower(concat('web', webSuffix))
var storageAccountName = toLower(concat('st', storageSuffix))
var appServicePlanName = toLower(concat('asp', webSuffix))

// Create the App Service Plan. Notice the conditional SKU selection based on the environment.
// For production, we use a Standard (S1) tier, and for non-prod, a Basic (B1) tier.
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: environment == 'prod' ? 'S1' : 'B1'
    tier: environment == 'prod' ? 'Standard' : 'Basic'
  }
}

// Create the Storage Account using the robustly generated name. We choose StorageV2
// with Standard_LRS replication and enforce HTTPS-only traffic.
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// Create the Web App and set its server farm (App Service Plan) ID.
// The web app's app settings dynamically incorporate the storage account details
// using concat() so that the value is built at deployment time.
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  dependsOn: [
    appServicePlan
    storageAccount
  ]
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: concat(
            'DefaultEndpointsProtocol=https;AccountName=',
            storageAccount.name,
            ';EndpointSuffix=core.windows.net'
          )
        }
      ]
    }
  }
}

// Outputs to display the URLs after deployment.
output webAppUrl string = webApp.properties.defaultHostName
output storageAccountNameOut string = storageAccount.name
