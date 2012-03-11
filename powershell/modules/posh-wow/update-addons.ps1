#########################################################################
# Name: update-addons.ps1
# Version: 2.0
# Author: Peter Provost <peter@provost.org>
#
# Usage: update-addons
#
# Remarks: This is a simple powershell script for updating your
# 	World of Warcraft addons. #
#
#########################################################################
param ( 
	[switch] $skipSvn,
	[switch] $scan,
	[switch] $debug,
	[string] $addon = ""
);

$scripts = (split-path $profile); # I keep my personal .PS1 files in the same folder as my $profile
$manifestFile = join-path $scripts "modules\posh-wow\update-addons.csv"
$manifest = import-csv $manifestFile

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

$tempDir = join-path (get-content env:\temp) "PsWowUpdater";
if (-not (test-path $tempDir)) { 
	new-item -type directory -path $tempDir; 
}

if ($scan.isPresent) {
	$set = @{}
	$manifest | %  { $set[$_.Name] = $true }
	write-host -foreground "Yellow" "Not configured"
	get-childitem $wowAddonDir | 
		? { $_.PSIsContainer -and $_.Name -notmatch "Blizzard" } | 
		? { -not $set.ContainsKey($_.Name) } | 
		% { write-host $_.Name }

	write-host ""

	write-host -foreground "Yellow" "Not installed"
	$set.Keys | ? { -not (test-path "$wowAddonDir\$_") }

	return
}

$wc = new-object System.Net.WebClient;
$wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.4) Gecko/2008102920 Firefox/3.0.4")
$stateFile = "PSUpdateAddons.state";



#########################################################################
# Update functions
#
function update-addon {
	param (
		$url = $(throw "url required"),
		$fileName = $(throw "fileName required")
	)

	$tempFilePath = join-path $tempDir $fileName
	downloadextract-addon -uri $url -tempFile $tempFilePath
}

function downloadextract-addon
{
	param (
		$uri = $(throw "uri required"),
		$tempFile = $(throw "tempFile required")
	)

	write-host -foregroundColor darkgray "`tDownloading $uri..." -noNewLine;
	$wc.DownloadFile( $uri, $tempFile );
	write-host -foregroundColor darkgray "done.";

	$ext = [System.IO.Path]::GetExtension($tempFile);
	switch ($ext) {
		".rar" { 
			write-host -foregroundColor darkgray "`tExtracting RAR Archive..." -noNewLine;
			if ($verbose) { & unrar x -o+ $tempFile $wowAddonDir; } else { & unrar x -o+ $tempFile $wowAddonDir | out-null; }
		}
		".zip" { 
			write-host -foregroundColor darkgray "`tExtracting ZIP Archive..." -noNewLine;
			if ($verbose) { & unzip -o $tempFile -d $wowAddonDir; } else { & unzip -o $tempFile -d $wowAddonDir | out-null; }
		}
		default { write-host -foregroundColor red "UNKNOWN EXTENSION TYPE! ($ext)" }
	}
	write-host -foregroundColor darkgray "done.";

	write-host -foregroundColor darkgray "`tDeleting zip file..." -noNewLine;
	remove-item $tempFile;
	write-host -foregroundColor darkgray "done.";
}

#########################################################################
# Updater functions
#
# These functions are named with a special form that enables 
# dynamic calling based on the source specified in the CSV file
#
function update-wowi {
	param (
		$name = $(throw "You must provide the addon name"),
		$uid = $(throw "You must provide the addon UID")
	)

	write-host "$name - wowinterface.com $uid"

	$addonPath = join-path $wowAddonDir $name
	$stateFilePath = join-path $addonPath $stateFile
	$localVer = ""
	if (test-path $stateFilePath) { 
		$localVer = (get-content $stateFilePath)
	}

	$uri = "http://www.wowinterface.com/patcher$uid.xml"
	$wowiXml = [xml] $wc.DownloadString($uri)

	$downloadUrl = $wowiXml.UpdateUI.Current.UIFileURL
	$remoteVer = $wowiXml.UpdateUI.Current.UIVersion
	$fileName = $wowiXml.UpdateUI.Current.UIFile

	if ($localVer -ne $remoteVer) {
		write-host -foregroundColor yellow "`tUpdate required: Current ver=$localVer, Remote ver=$remoteVer"
		update-addon -url $downloadUrl -fileName $fileName
		$remoteVer > $stateFilePath
	} else {
		write-host -foregroundColor green "`tAddon up-to-date. Skipping."
	}
}

function update-wowace {
	param (
		$name = $(throw "You must provide the addon name"),
		$uid = $(throw "You must provide the addon UID"),
		$urlBase = "http://www.wowace.com"
	)

	write-host "$name - $urlBase - $uid"

	$addonPath = join-path $wowAddonDir $name
	$stateFilePath = join-path $addonPath $stateFile
	$lastUrl = ""
	if (test-path $stateFilePath) { 
		$lastUrl = (get-content $stateFilePath)
	}

	$api_key = "?api-key=$(get-content ~\.wowace-apikey.txt)"

	# Screenscrape out the links...

	$html = $wc.DownloadString("$urlBase/projects/$uid/$api_key")
	$tmp = ($html -match ".*<li class=`"user-action user-action-download`"><a href=`"(?<url>.*)`">Download</a>.*")
	if ($tmp -eq $false) {
		write-host -foregroundColor red "ERROR PARSING WOWACE HTML!"
		return
	}

	$url_path = $matches["url"]
	$url = "$urlBase$url_path$api_key"
	if ($debug.IsPresent) { write-host -foregroundColor darkgray "`tFirst URL: $url" }
	$html2 = $wc.DownloadString($url)

	$tmp = ($html2 -match ".*<a href=`"(?<url>.*)`">Download</a>.*")
	if ($tmp -eq $false) {
		write-host -foregroundColor red "ERROR PARSING WOWACE HTML!"
		return
	}

	$currentUrl = $matches["url"]
	$filename = $currentUrl.Split("/")[-1]
	$filename = $filename.Split("?")[0]

	if ($lastUrl -ne $currentUrl) {
		write-host -foregroundColor yellow "`tUpdate required: Remote ver=$filename"
		if ($debug.IsPresent) { write-host -foregroundColor darkgray "`tSecond URL: $currentUrl" }
		update-addon -url $currentUrl -fileName $filename
		$currentUrl > $stateFilePath
	} else {
		write-host -foregroundColor green "`tAddon up-to-date. Skipping."
	}
}

function update-curseforge {
	param (
		$name = $(throw "You must provide the addon name"),
		$uid = $(throw "You must provide the addon UID")
	)

	# Same as wowace with just a different
	update-wowace -name $name -uid $uid -urlBase "http://www.curseforge.com"
}

function update-svn {
	param (
		$name = $(throw "You must provide the addon name"),
		$uid = $(throw "You must provide the addon UID")
	)

	write-host "$name - svn $uid"

	if ($skipSvn.isPresent) {
		write-host -foregroundColor yellow "`tSkipping SVN working copy"
		return
	}

	$addonPath = join-path $wowAddonDir $name
	if (-not (test-path $addonPath)) {
		$output = & { svn checkout $uid $addonPath };
	} else {
		$output = & { svn update $addonPath };
	}

	$output | % { write-host -foregroundcolor darkgray "`t$_" };
}

function update-git {
	param (
		$name = $(throw "You must provide the addon name"),
		$uid = $(throw "You must provide the addon UID")
	)

	write-host "$name - git $uid"

	$addonPath = join-path $wowAddonDir $name
	if (-not (test-path $addonPath)) {
		$output = & { git clone $uid $addonPath };
	} else {
		$output = & { pushd $addonPath; git pull; popd };
	}

	$output | % { write-host -foregroundcolor darkgray "`t$_" };

}

function update-skip {
	param (
			$name = $(throw "You must provide the addon name."),
			$uid = "No note provided"
			)

	write-host "$name - skipping $uid"
	write-host -foregroundColor yellow "`tSkipping $name - $uid"
}

function update-packaged-with {
	param (
			$name = $(throw "You must provide the addon name."),
			$uid = "No note provided"
			)

	write-host "$name - packaged with $uid"
	write-host -foregroundColor yellow "`tSkipping $name - $uid"
}

# Single addon mode: the -addon flag
if ($addon -ne "") {
	$manifest | ? { $_.Name -eq $addon } | % {
		$source = $_.Source; $name = $_.Name; $uid = $_.UID
		$name = $name.Replace("'", "``'") # stupid escapes
		if ($source -eq $null) { $source = "skip" }
		$expr = "update-$source -name $name -UID $uid"
		invoke-expression $expr
	}

	return
}

#########################################################################
# Main processing loop
#
# This loop processes everything in the manifest, passing the info to
# one of the helper methods defined above.
#
$manifest | % {
	$source = $_.Source; $name = $_.Name; $uid = $_.UID
	$name = $name.Replace("'", "``'")
	if ($source -eq $null) { $source = "skip" }
	$expr = "update-$source -name $name -UID $uid"
	invoke-expression $expr
}

