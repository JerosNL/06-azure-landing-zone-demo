Configuration DomainController {
    param (
        [Parameter(Mandatory)]
        [string]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$AdminCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName NetworkingDsc

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
            ActionAfterReboot  = 'ContinueConfiguration'
        }

        WindowsFeature ADDS {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        WindowsFeature DNS {
            Ensure = 'Present'
            Name   = 'DNS'
        }

        WindowsFeature RSATADTools {
            Ensure    = 'Present'
            Name      = 'RSAT-AD-Tools'
            DependsOn = '[WindowsFeature]ADDS'
        }

        WindowsFeature RSATDNSTools {
            Ensure    = 'Present'
            Name      = 'RSAT-DNS-Server'
            DependsOn = '[WindowsFeature]DNS'
        }

        ADDomain CreateDomain {
            DomainName                    = $DomainName
            Credential                    = $AdminCredential
            SafemodeAdministratorPassword = $AdminCredential
            DependsOn                     = '[WindowsFeature]ADDS'
        }

        WaitForADDomain WaitForDomain {
            DomainName = $DomainName
            DependsOn  = '[ADDomain]CreateDomain'
        }

        ADOrganizationalUnit OUUsers {
            Name                            = 'VanderMeer Users'
            Path                            = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            ProtectedFromAccidentalDeletion = $true
            Ensure                          = 'Present'
            DependsOn                       = '[WaitForADDomain]WaitForDomain'
        }

        ADOrganizationalUnit OUComputers {
            Name                            = 'VanderMeer Computers'
            Path                            = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            ProtectedFromAccidentalDeletion = $true
            Ensure                          = 'Present'
            DependsOn                       = '[WaitForADDomain]WaitForDomain'
        }

        ADOrganizationalUnit OUGroups {
            Name                            = 'VanderMeer Groups'
            Path                            = "DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
            ProtectedFromAccidentalDeletion = $true
            Ensure                          = 'Present'
            DependsOn                       = '[WaitForADDomain]WaitForDomain'
        }
    }
}