param(
	$version = "Latest"
)

$last_change_url = "http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/LAST_CHANGE"
$dl_rool_url = "http://commondatastorage.googleapis.com/chromium-browser-continuous/index.html?path=Win/"

if ([string]::compare($version, "latest", $false)) {
	Write-Host "Determining latest version"
	$response = Invoke-WebRequest $last_change_url

	if ($res.StatusCode -ne 200) {
		Write-Error ("{0} received trying to get last nightly build number" -f $res.StatusCode)
		return
	}

	$version = $response.Content
} 

$url = $dl_rool_url + $version
$download_url = ("http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/{0}/mini_installer.exe" -f $version)

Write-Output ("Downloading version {0} from {1}" -f $version,$download_url)
$file = Get-WebFile -url $download_url -filename (join-path $env:temp "mini_installer.exe")

Write-Output ("Executing {0}" -f $file)
& $file

Write-Output ("Deleting temp file {0}" -f $file)
Remove-Item $file
