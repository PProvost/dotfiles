param([string] $startAddress = "192.168.0.1", $count=254)

$lastDot = $startAddress.LastIndexOf(".")
$subnet = $startAddress.Substring(0, $lastDot+1)
$ip = [int] $startAddress.SubString($lastDot + 1)

Write-Host "IP Address"
Write-Host "----------------------------------------"
Do { 
	$address = $subnet + $ip
	$pingStatus = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$address'"
	if($pingStatus.StatusCode -eq 0) {
		"{0,0} {1,5} {2,5}" -f $pingStatus.Address, $pingStatus.StatusCode," ON NETWORK"
	} else {
		"{0,0} {1,5} {2,5}" -f $pingStatus.Address, $pingStatus.StatusCode, " xxxxxxxxx"
	}
	$ip++
} until ($ip -eq $count)

