@description('Azure region for all resources')
param location string = resourceGroup().location

@description('AKS cluster name')
param aksName string

@description('ACR name (globally unique, lowercase, 5-50 chars)')
param acrName string

@description('VNet name')
param vnetName string = 'vnet-aks-lab'

@description('AKS subnet name')
param aksSubnetName string = 'snet-aks'

@description('AKS node VM size (use DSv4 to match your quota)')
param nodeVmSize string = 'Standard_D2s_v4'

@minValue(1)
@description('AKS node count')
param nodeCount int = 1

@description('Enable Azure Monitor for containers (adds cost). Keep false for tight budgets; enable only when testing HPA if needed.')
param enableMonitoring bool = false

@description('Log Analytics workspace name (only used if enableMonitoring=true)')
param lawName string = 'law-aks-lab'

var vnetCidr = '10.10.0.0/16'
var aksSubnetCidr = '10.10.1.0/24'

// VNet + Subnet
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ vnetCidr ] }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetCidr
        }
      }
    ]
  }
}

// ACR Basic
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: { name: 'Basic' }
  properties: {
    adminUserEnabled: false
  }
}

// Log Analytics (optional)
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (enableMonitoring) {
  name: lawName
  location: location
  properties: {
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// AKS
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: aksName
    enableRBAC: true

    agentPoolProfiles: [
      {
        name: 'nodepool1'
        mode: 'System'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, aksSubnetName)
      }
    ]

    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }

    // Optional monitoring addon (Container Insights). This increases costs.
    addonProfiles: enableMonitoring ? {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: law.id
        }
      }
    } : null
  }
}

// Attach ACR to AKS via role assignment (AcrPull) on the kubelet identity
// NOTE: kubelet identity is created by AKS; we can reference it after AKS exists.
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, aks.name, 'acrpull')
  scope: acr
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    aks
    acr
  ]
}

output aksNameOut string = aks.name
output acrLoginServer string = acr.properties.loginServer
output vnetId string = vnet.id
