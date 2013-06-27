<#
    .NOTES
			Copyright (c) Peter Provost

			Licensed under the Apache License, Version 2.0 (the "License");
			you may not use this file except in compliance with the License.
			You may obtain a copy of the License at

				 http://www.apache.org/licenses/LICENSE-2.0

			Unless required by applicable law or agreed to in writing, software
			distributed under the License is distributed on an "AS IS" BASIS,
			WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
			See the License for the specific language governing permissions and
			limitations under the License.

	.SYNOPSIS
		Downloads and installs the latest build of Chromium from the official 
		continuous build server.

	.DESCRIPTION
		Downloads and installs the latest build of Chromium from the official 
		continuous build server.

	.PARAMETER Version
		[Optional] The specific version number you want to install.
		Default: "Latest"

	.PARAMETER OpenBuildBot
		[Optional] Causes the script to open the BuildBot page in your default browser 
		and terminate. Use of this parameter will prevent the script from downloading
		or installing anything.
		Default: $false

	.PARAMETER CheckForUpdate
		[Optional] Causes the script to report the latest build available on the
		Chromium continuous build server. Use of this parameter will prevent the 
		script from downloading or installing anything.
		Default: $false

#>
 
param(
	$version = "Latest",
	[switch] $openBuildBot = $false,
	[switch] $checkForUpdate = $false
)

function GetLatestVersion {
	$response = Invoke-WebRequest $last_change_url

	if ($res.StatusCode -ne 200) {
		Write-Error ("{0} received trying to get last nightly build number" -f $res.StatusCode)
		return
	}

	return $response.Content
}

function GetInstalledVersion {

}

if ($openBuildBot) {
	[Diagnostics.Process]::Start("http://build.chromium.org/p/chromium/waterfall")
	return
}

if ($checkForUpdate) {
	Write-Host ("Latest version is {0}" -f $(GetLatestVersion))
	return
}

$restartChrome = false
$last_change_url = "http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/LAST_CHANGE"
$dl_rool_url = "http://commondatastorage.googleapis.com/chromium-browser-continuous/index.html?path=Win/"

Write-host "Updating Chromium browser from the BuildBot http://build.chromium.org/p/chromium/waterfall" -fore Yellow

$proc = Get-Process "chrome" -ErrorAction SilentlyContinue
if ($proc -ne $null) {
	Write-Host "Chromium is currently running!" -fore Yellow
	Write-Host "Exit the program or it will be forcibly closed." -fore Yellow
	Write-host "Press any key to continue or Ctrl+C to abort." -fore Yellow
	
	$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	if ($proc -ne $null) {
		$restartChrome = $true
		Stop-Process -name "chrome" -ErrorAction SilentlyContinue
	}
}

if ([string]::compare($version, "latest", $false)) {
	Write-Host "Determining latest version"
	$version = GetLatestVersion
} 

$url = $dl_rool_url + $version
$download_url = ("http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/{0}/mini_installer.exe" -f $version)

Write-Output ("Downloading version {0} from {1}" -f $version,$download_url)
$file = Get-WebFile -url $download_url -filename (join-path $env:temp "mini_installer.exe")

Write-Output ("Executing {0}" -f $file)
& $file

Write-Output ("Deleting temp file {0}" -f $file)
Remove-Item $file

if ($restartChrome -eq $true) {
	& (join-path $env:LOCALAPPDATA "Chromium\Application\chrome.exe") --restore-last-session
}
