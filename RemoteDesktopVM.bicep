param location string = 'northeurope'

@description('admin username')
@minLength(3)
@maxLength(15)
param adminUsername string = 'mlvcsuperuser'

//@secure()
param adminPass string = '$RgV^IMbaGb16y'
//IP address is 52.169.45.233

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet'
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
        '10.13.37.0/24'
       ]
     }
     subnets: [
      { 
        name: 'testVMsubnet'
        properties: {
          addressPrefix: '10.13.37.0/24'
        }
      }
     ]
  }
}

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'networksecuritygroup'
  location: location
  properties: {
     securityRules: [
       {
        name: 'Allow-RDP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*' 
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          description: 'Allows remote desktop'
        } 
       }
     ]
     

  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'publicIP'
  location: location
  properties:{
     publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'testVMnic'
  location:location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
           subnet: {
             id: vnet.properties.subnets[0].id
           }
        publicIPAddress: {id:publicIP.id}
        }
      }
    ]
    networkSecurityGroup: {
      id: networksecuritygroup.id
    }
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: 'testVM'
  location: 'northeurope' 
   properties: {
     hardwareProfile: {
       vmSize: 'Standard_B1s'
     }
      osProfile: {
        computerName: 'testVM'
        adminUsername: adminUsername
        adminPassword: adminPass
      }
      storageProfile: {
         imageReference: {
          publisher: 'MicrosoftWindowsDesktop'
          offer: 'windows-10'
          sku: 'win10-21h2-ent'
          version:'latest'
         }
      }
      networkProfile: {
        networkInterfaces:[
          {
            id: nic.id
          }
        ]
      }
   }
}
