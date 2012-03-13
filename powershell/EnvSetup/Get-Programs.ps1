# Get-Programs.ps1
# This is my personal "machine setup" file downloader
# It is completely self contained so I can just download this single file
# and run it to get my fav installers downloaded for me

# Configuration
$files = @{
	# Curl for command line web downloads (x86)
	curl			= 'http://curl.haxx.se/gknw.net/win32/curl-7.24.0-ssl-sspi-zlib-static-bin-w32.zip'

	# MsysGit (x86)
	git				= 'http://msysgit.googlecode.com/files/Git-1.7.9-preview20120201.exe'

	# KDiff3 (x86)
	kdiff3		= 'http://sourceforge.net/projects/kdiff3/files/latest/download?source=files'

	# 7-zip (x64)
	sevenZip	= 'http://downloads.sourceforge.net/sevenzip/7z920-x64.msi'

	# Vim for Windows (works x86 and x64)
	gvim				= 'http://ftp.vim.org/pub/vim/pc/gvim73_46.exe'

	# msvcredist_x64 - required by HardLinkShellExt_x64
	linkshellreq = 'http://download.microsoft.com/download/6/B/B/6BB661D6-A8AE-4819-B79F-236472F6070C/vcredist_x64.exe'

	# HardLinkShellExt_x64 - Shows hard links and junctions in Windows Explorer
	linkshell = 'http://schinagl.priv.at/nt/hardlinkshellext/HardLinkShellExt_X64.exe'
}
$downloadDir = "~\Downloads\EnvSetup"

# Get-WebFile 3.6 (aka wget for PowerShell)
# by Joel Bennett http://poshcode.org/417
function Get-WebFile {
   param( 
      $url = (Read-Host "The URL to download"),
      $fileName = $null,
      [switch]$Passthru,
      [switch]$quiet
   )
   
   $req = [System.Net.HttpWebRequest]::Create($url);
   $res = $req.GetResponse();
 
   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   } 
   elseif((!$Passthru -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)))
   {
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/""'")
      if(!$fileName) {
         $fileName = $res.ResponseUri.Segments[-1]
         $fileName = $fileName.trim("\/")
         if(!$fileName) { 
            $fileName = Read-Host "Please provide a file name"
         }
         $fileName = $fileName.trim("\/")
         if(!([IO.FileInfo]$fileName).Extension) {
            $fileName = $fileName + "." + $res.ContentType.Split(";")[0].Split("/")[1]
         }
      }
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   }
   if($Passthru) {
      $encoding = [System.Text.Encoding]::GetEncoding( $res.CharacterSet )
      [string]$output = ""
   }
 
   if($res.StatusCode -eq 200) {
      [int]$goal = $res.ContentLength
      $reader = $res.GetResponseStream()
      if($fileName) {
         $writer = new-object System.IO.FileStream $fileName, "Create"
      }
      [byte[]]$buffer = new-object byte[] 4096
      [int]$total = [int]$count = 0
      do
      {
         $count = $reader.Read($buffer, 0, $buffer.Length);
         if($fileName) {
            $writer.Write($buffer, 0, $count);
         } 
         if($Passthru){
            $output += $encoding.GetString($buffer,0,$count)
         } elseif(!$quiet) {
            $total += $count
            if($goal -gt 0) {
               Write-Progress "Downloading $url" "Saving $total of $goal" -id 0 -percentComplete (($total/$goal)*100)
            } else {
               Write-Progress "Downloading $url" "Saving $total bytes..." -id 0
            }
         }
      } while ($count -gt 0)
      
      $reader.Close()
      if($fileName) {
         $writer.Flush()
         $writer.Close()
      }
      if($Passthru){
         $output
      }
   }
   $res.Close(); 
   if($fileName) {
      ls $fileName
   }
}

if ((test-path $downloadDir) -eq $false) {
	mkdir $downloadDir | out-null
}

push-location $downloadDir

$dlfiles = @()
$files.GetEnumerator() | % {
	$dlfiles += get-webfile $_.Value
}

pop-location

$dlfiles
