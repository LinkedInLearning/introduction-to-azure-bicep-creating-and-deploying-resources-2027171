param location string = resourceGroup().location
param vnetName string = 'myVnet'
param subnet1Name string = 'subnet1'
param subnet2Name string = 'subnet2'
param firewallName string = 'myFirewall'
param vmNamePrefix string = 'myVM'
param webAppName string = 'myWebApp'
param storageAccountName string = uniqueString(resourceGroup().id, 'storage')
param logAnalyticsName string = 'myLogAnalytics'

@secure()
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      {
        name: subnet1Name
        properties: { addressPrefix: '10.0.1.0/24' }
      }
      {
        name: subnet2Name
        properties: { addressPrefix: '10.0.2.0/24' }
      }
    ]
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-02-01' = {
  name: firewallName
  location: location
  properties: {
    sku: { name: 'AZFW_VNet', tier: 'Standard' }
    ipConfigurations: [
      {
        name: 'firewallIpConfig'
        properties: {
          subnet: { id: vnet.properties.subnets[0].id }
          publicIPAddress: null // Add a public IP resource if needed
        }
      }
    ]
  }
}

resource vm1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${vmNamePrefix}1'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    adminUsername: 'azureuser'
    adminPassword: adminPassword

    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmNamePrefix}1-nic')
        }
      ]
    }
  }
}

resource vm1Nic 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: '${vmNamePrefix}1-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: vnet.properties.subnets[0].id }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${vmNamePrefix}2'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: '${vmNamePrefix}2'
      adminUsername: 'azureuser'
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmNamePrefix}2-nic')
        }
      ]
    }
  }
}

resource vm2Nic 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: '${vmNamePrefix}2-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: vnet.properties.subnets[0].id }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {}
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-04-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${webAppName}-plan'
  location: location
  sku: { name: 'B1', tier: 'Basic' }
  properties: {}
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'STORAGE_ACCOUNT'
          value: storage.name
        }
      ]
    }
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'webAppDiag'
  scope: webApp
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: { enabled: false, days: 0 }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: { enabled: false, days: 0 }
      }
    ]
  }
}
