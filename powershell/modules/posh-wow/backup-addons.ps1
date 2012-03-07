# Configuration - change these as needed
if (test-path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft")
{
	$wowDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft").InstallPath;
	$wowAddonDir = join-path $wowDir "Interface\Addons";
}
else
{
	$wowAddonDir = "C:\Program Files\World of Warcraft\Interface\Addons";
}

$zipFilename = "Addons." + [DateTime]::Now.ToString("yyyyMMddTHHmmss") + ".zip"
$interfaceDir = split-path $wowAddonDir

$zipPath = join-path $interfaceDir $zipFilename
$sourcePath = $wowAddonDir + "\*.*"

pushd $interfaceDir
zip -r -1 $zipFilename "Addons\*.*"
popd
