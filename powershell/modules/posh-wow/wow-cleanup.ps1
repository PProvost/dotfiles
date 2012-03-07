# Some helper and path stuff
function strip-extension ([string] $filename) 
{
	[System.Io.Path]::GetFileNameWithoutExtension($filename)
} 

if (test-path "HKLM:\SOFTWARE\Wow6432Node\Blizzard Entertainment\World of Warcraft") {
	$wowDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Wow6432Node\Blizzard Entertainment\World of Warcraft").InstallPath;
} else {
	if (test-path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft") {
		$wowDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft").InstallPath;
	} else {
		$wowDir = "C:\Program Files\World of Warcraft\";
	}
}
$wowAddonDir = join-path $wowDir "Interface\Addons";

# Cleanup all SVs that don't have an associated addon
function clean-svdir ([string] $dirname)
{
	ls $dirname\*.lua | ? { (test-path (join-path -path $wowAddonDir -childPath (strip-extension($_.Name)))) -eq $false } | rm
}

write-host -foregroundColor yellow "Deleting all extraneous SavedVariables files"
clean-svdir "$wowDir\WTF\Account\PPROVOST\SavedVariables"
ls $wowDir\WTF\Account\PPROVOST\Dragonblight | ? { $_.PSIsContainer -eq $true } | ? { join-path $_.FullName "SavedVariables" | test-path } | % { clean-svdir (join-path $_.Fullname "SavedVariables") }

# Delete all .lua.bak files under WTF\Account\PProvost
write-host -foregroundColor yellow "Deleting all .lua.bak files"
ls -rec -fo "$wowDir\WTF\Account\PProvost\*" | ? { $_.Name.EndsWith(".lua.bak") } | rm

# Delete all Changelog files from the addons directories
# write-host -foregroundColor yellow "Deleting all addon Changelog files"
# ls -rec -fo "$wowDir\Interface\Addons\*" | ? { $tmp = $_.Directory.Name; $_ -match "Changelog-$tmp*" } | rm
