# namespaces to support OData

$namespace = @{
    a = "http://www.w3.org/2005/Atom"
    e = "http://schemas.microsoft.com/ado/2008/09/edm"
    d = "http://schemas.microsoft.com/ado/2007/08/dataservices"
    r = "http://schemas.microsoft.com/ado/2007/08/dataservices/related/"
    m = "http://schemas.microsoft.com/ado/2007/08/dataservices/metadata"
}

Function Get-Webclient {
    $wc = New-Object Net.WebClient
    $wc.UseDefaultCredentials = $true

    $wc
}

Function Fix-Url ($url) {
    if($url.EndsWith('/') -Or $url.EndsWith('\')) {
        return $url
    }
    
    "$url/"
}

Function Get-ODataFeedEntryPropertyName ($targetXML) {
    $xpath = "//a:entry[1]//m:properties"

    $result = Select-Xml $targetXML -XPath $xpath -Namespace $namespace
    
    $result.Node |
      Get-Member -MemberType Property | 
      Select -ExpandProperty Name
}

Filter Convert-ODataToPSObject {
    
    $pn = Get-ODataFeedEntryPropertyName $_
    
    Select-Xml $_ -XPath "//a:entry" -Namespace $namespace | ForEach {
        $links = Select-Xml $_.Node -Namespace $namespace -XPath "a:link" | % {$_.node}
        $payload = Select-Xml $_.Node -XPath "a:content/m:properties" -Namespace $namespace | % {$_.node}
        if(!$payload) {
            # if the content element does not contain the <m:properties> section, then this is an MLE
            $payload = Select-Xml $_.Node -XPath "m:properties" -Namespace $namespace | % {$_.node}
        }
        
        foreach($record in $payload) {
            $properties = @()
            foreach($propertyName in $pn) {
                # 
                # TODO: Fix this problem
                #
                # Exception calling "Tags" with "0" argument(s): "Unexpected token '¢"
                $v = $record.$propertyName
                if($v) {
                    switch($record.$propertyName.GetType().Name) {
                        "XmlElement" { $data = $record.$propertyName.'#text' }
                        "String"     { $data = $record.$propertyName }
                    }
                    
                    $data = $data -replace '"', '`"' -replace '"', '' -replace "'", "''"
                    $properties += "`$$($propertyName) = '$($data)'`r`n"
                }
            }
        }
        
        $links | foreach {$functions = @()} { 
            $functions += New-ODataScriptMethod $_.title "$($base)$($_.href)" 
        }
        
$module = @"
New-Module -AsCustomObject {
$properties
$functions
    
    Function GetOperations { 
        `$this | gm -MemberType ScriptMethod | ?{`$_.Name -ne 'GetOperations'} | select -ExpandProperty Name
    }
    
    Export-ModuleMember -Variable * -Function *
}
"@ 
        #$module | Out-String | Write-Host
        Invoke-Expression $module
    }    
}

Function Get-ODataFeed  {
	param(
		[Parameter(ValueFromPipelineByPropertyName=$true)]
        $uri,
        [switch]$raw
	)

	Process {
		$xml = (get-webclient).DownloadString($uri)
		if(!$raw) { [xml] $xml } 
          else { $xml }
	}
}

$script:base
Function New-ODataService {
    param (
        $service
    )
    
    $svcXML = Get-ODataFeed $service
    $script:base = Fix-Url $svcXML.service.base
    
    $svcXML.service.workspace.collection | ForEach {$functions = @()} {
        $functions += New-ODataScriptMethod $_.title "$($base)$($_.href)"
    }
    
$module = @"
New-Module -AsCustomObject {
    
    $functions
    
    Function GetOperations { 
        `$this | gm -MemberType ScriptMethod | ?{`$_.Name -ne 'GetOperations'} | select -ExpandProperty Name
    }
}
"@
    Invoke-Expression $module
}

Function Get-ODataMetadata { Get-ODataFeed "$base`$metadata" }

Function New-ODataScriptMethod($functionName, $uri) {
@"
    Function $($functionName) (`$parameters,[switch]`$raw) {
        if(!`$parameters) {
            `$target = "$($uri)"
        } else {
            `$target = "$($uri)?`$parameters"
        }
        
        #write-host `$target
        
        if(`$raw -eq `$true) {
            Get-ODataFeed `$target -raw 
        } else {
            Get-ODataFeed `$target | Convert-ODataToPSObject   
        }
    }

"@
}

Export-ModuleMember -Function *-OData* #-Variable namespace 