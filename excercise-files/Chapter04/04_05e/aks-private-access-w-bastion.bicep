param location string = resourceGroup().location
param hubVnetName string = 'hub-vnet'
param spokeVnetName string = 'spoke-vnet'
param bastionSubnetName string = 'AzureBastionSubnet'
param jumpboxSubnetName string = 'JumpboxSubnet'
param privateEndpointSubnetName string = 'PrivateEndpointSubnet'
param aksSubnetName string = 'AksSubnet'
param aksClusterName string = 'aks-cluster'
param dnsZoneName string = 'privatelink.region.azmk8s.io'
param jumpboxVmName string = 'jumpbox-vm'
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

// Hub VNet
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      {
        name: bastionSubnetName
        properties: { addressPrefix: '10.0.0.0/24' }
      }
      {
        name: jumpboxSubnetName
        properties: { addressPrefix: '10.0.1.0/24' }
      }
    ]
  } 
}

// Spoke VNet
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.1.0.0/16'] }
    subnets: [
      {
        name: privateEndpointSubnetName
        properties: { addressPrefix: '10.1.0.0/24' }
      }
      {
        name: aksSubnetName
        properties: { addressPrefix: '10.1.1.0/24' }
      }
    ]
  }
}

// Hub <-> Spoke Peering
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${hubVnet.name}/hub-to-spoke'
  properties: {
    remoteVirtualNetwork: { id: spokeVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${spokeVnet.name}/spoke-to-hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// Public IP for Bastion
resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: 'bastion-pip'
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Azure Bastion
resource bastion 'Microsoft.Network/bastionHosts@2023-02-01' = {
  name: 'bastion-host'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ip-config'
        properties: {
          subnet: { id: hubVnet.properties.subnets[0].id }
          publicIPAddress: { id: bastionPip.id }
        }
      }
    ]
  }
}

// Jump Box NIC
resource jumpboxNic 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: '${jumpboxVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: hubVnet.properties.subnets[1].id }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// Jump Box VM
resource jumpboxVm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: jumpboxVmName
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
      computerName: jumpboxVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        { id: jumpboxNic.id }
      ]
    }
  }
}

// AKS Cluster (Private)
resource aks 'Microsoft.ContainerService/managedClusters@2023-05-02-preview' = {
  name: aksClusterName
  location: location
  properties: {
    dnsPrefix: 'aksdns'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        vnetSubnetID: spokeVnet.properties.subnets[1].id
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      dnsServiceIP: '10.2.0.10'
      serviceCidr: '10.2.0.0/24'
      dockerBridgeCidr: '172.17.0.1/16'
      outboundType: 'userDefinedRouting'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
  }
}

// Private DNS Zone for AKS
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2023-05-01' = {
  name: dnsZoneName
  location: 'global'
}

// VNet Link: Hub
resource hubDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2023-05-01' = {
  name: 'hub-link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: { id: hubVnet.id }
    registrationEnabled: false
  }
}

// VNet Link: Spoke
resource spokeDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2023-05-01' = {
  name: 'spoke-link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: { id: spokeVnet.id }
    registrationEnabled: false
  }
}
