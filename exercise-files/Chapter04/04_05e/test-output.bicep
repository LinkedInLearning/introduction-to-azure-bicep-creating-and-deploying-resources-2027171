@description('Location for all resources')
param location string = resourceGroup().location

@description('Prefix for resource names')
param prefix string = 'demo'

@description('Admin username for VMs')
param adminUsername string

@secure()
@description('Admin password for VMs')
param adminPassword string

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet1'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'subnet2'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// Azure Firewall
resource firewall 'Microsoft.Network/azureFirewalls@2023-02-01' = {
  name: '${prefix}-firewall'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'firewall-ip'
        properties: {
          subnet: {
            id: vnet::subnets[0].id
          }
          privateIPAddress: '10.0.1.4'
        }
      }
    ]
  }
}

// Network Interface for VMs
resource nic1 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: '${prefix}-nic1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet::subnets[0].id
          }
          privateIPAddress: '10.0.1.5'
        }
      }
    ]
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: '${prefix}-nic2'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet::subnets[0].id
          }
          privateIPAddress: '10.0.1.6'
        }
      }
    ]
  }
}

// Virtual Machines
resource vm1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${prefix}-vm1'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm1'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${prefix}-vm2'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm2'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
  }
}

// Storage Account
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${prefix}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-04-01' = {
  name: '${prefix}-log'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Azure Monitor Diagnostic Setting (example for VM1)
resource diagSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${prefix}-diag-vm1'
  scope: vm1
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// App Service Plan (for Web App)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${prefix}-asp'
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
  }
  properties: {
    reserved: false
  }
}

// Web App (in subnet2, using VNet integration)
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${prefix}-webapp'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      vnetRouteAllEnabled: true
      vnetName: vnet.name
    }
    httpsOnly: true
  }
}

// VNet Integration for Web App (requires manual setup or Azure CLI for subnet delegation)
// See: https://learn.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet

// Outputs
output vnetId string = vnet.id
output vm1Name string = vm1.name
output vm2Name string = vm2.name
output webAppName string = webApp.name
output storageAccountName string = storage.name
output logAnalyticsWorkspaceId string = logAnalytics.id
