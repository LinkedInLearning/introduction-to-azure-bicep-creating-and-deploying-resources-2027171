param location string = 'westus2'
param vnetName string = 'myVnet'
param vnetAddressPrefix string = '192.168.0.0/16'
param subnetName string = 'mySubnet'
param subnetPrefix string = '192.168.0.0/24'
param natGatewayName string = 'myNATgateway'
param natPublicIPName string = 'myNATgateway-ip'
param domainNameLabel string = 'gw-ltppozpodhz54'
param publicIPAddress string = '20.64.135.87'

resource natGateway 'Microsoft.Network/natGateways@2024-05-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natPublicIP.id
      }
    ]
  }
}

resource natPublicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: natPublicIPName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: publicIPAddress
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: domainNameLabel
      fqdn: '${domainNameLabel}.${location}.cloudapp.azure.com'
    }
    ipTags: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          natGateway: {
            id: natGateway.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
