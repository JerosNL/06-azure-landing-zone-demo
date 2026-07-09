Configuration ManagementServer {

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost {

        WindowsFeature RSATADTools {
            Ensure = 'Present'
            Name   = 'RSAT-AD-Tools'
        }

        WindowsFeature RSATADPowerShell {
            Ensure = 'Present'
            Name   = 'RSAT-AD-PowerShell'
        }

        WindowsFeature RSATDNSTools {
            Ensure = 'Present'
            Name   = 'RSAT-DNS-Server'
        }

        WindowsFeature RSATGPOTools {
            Ensure = 'Present'
            Name   = 'GPMC'
        }

        WindowsFeature RSATDHCPTools {
            Ensure = 'Present'
            Name   = 'RSAT-DHCP'
        }
    }
}