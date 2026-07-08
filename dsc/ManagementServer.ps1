Configuration ManagementServer {

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost {

        WindowsFeature RSAT {
            Ensure = 'Present'
            Name   = 'RSAT'
        }

        WindowsFeature RSATADTools {
            Ensure    = 'Present'
            Name      = 'RSAT-AD-Tools'
            DependsOn = '[WindowsFeature]RSAT'
        }

        WindowsFeature RSATDNSTools {
            Ensure    = 'Present'
            Name      = 'RSAT-DNS-Server'
            DependsOn = '[WindowsFeature]RSAT'
        }

        WindowsFeature RSATGPOTools {
            Ensure    = 'Present'
            Name      = 'GPMC'
            DependsOn = '[WindowsFeature]RSAT'
        }

        WindowsFeature RSATDHCPTools {
            Ensure    = 'Present'
            Name      = 'RSAT-DHCP'
            DependsOn = '[WindowsFeature]RSAT'
        }
    }
}