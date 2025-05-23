param virtualNetworks_myVnet_name string = 'myVnet'
param natGateways_myNATgateway_name string = 'myNATgateway'
param publicIPAddresses_myNATgateway_ip_name string = 'myNATgateway-ip'

resource natGateways_myNATgateway_name_resource 'Microsoft.Network/natGateways@2024-05-01' = {
  name: natGateways_myNATgateway_name
  location: 'westus2'
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicIPAddresses_myNATgateway_ip_name_resource.id
      }
    ]
  }
}

resource publicIPAddresses_myNATgateway_ip_name_resource 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIPAddresses_myNATgateway_ip_name
  location: 'westus2'
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
    ipAddress: '20.64.135.87'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: 'gw-ltppozpodhz54'
      fqdn: 'gw-ltppozpodhz54.westus2.cloudapp.azure.com'
    }
    ipTags: []
  }
}

resource virtualNetworks_myVnet_name_resource 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworks_myVnet_name
  location: 'westus2'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'mySubnet'
        properties: {
          addressPrefix: '192.168.0.0/24'
          natGateway: {
            id: natGateways_myNATgateway_name_resource.id
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
