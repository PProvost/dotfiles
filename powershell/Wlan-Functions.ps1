# To use this, dot-source this into your PowerShell environment
# 
# Example:
# > Get-UnsecureWlanProfile | Remove-WlanProfile
#
# Source: http://www.leeholmes.com/blog/2013/06/06/removing-insecure-wireless-connections-with-powershell/

function Get-WlanProfile  
{  
    netsh wlan show all |  
        sls "^[\s]+Name\s+:" -Context 16 |  
        % {  
            $conn = [Ordered] @{}  
            $_.Line, $_.Context.PostContext[1], $_.Context.PostContext[15] | % {  
                $label,$value = $_ -split ':'  
                $conn[$label.Trim()] = $value.Trim()  
            } 
            $result = [PSCustomObject] $conn  
            if($result.Name -and $result.Authentication) { $result }  
        }  
} 

function Get-UnsecureWlanProfile  
{  
    Get-WlanProfile | ? {  
        ($_.Authentication -eq 'Open') -and  
        ($_."Connection mode" -match "automatically")  
    }  
} 

function Remove-WlanProfile  
{  
    param(  
        [Parameter(ValueFromPipelineByPropertyName)]  
        $Name  
    ) 

    netsh wlan delete profile name="$Name"  
}

