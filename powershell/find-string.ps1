<#
.Synopsis
	Searches text files by pattern and displays the results.
.Description
	Searches text files by pattern and displays the results.
.Notes
  Based on versions from http://weblogs.asp.net/whaggard/archive/2007/03/23/powershell-script-to-find-strings-and-highlight-them-in-the-output.aspx and from http://poshcode.org/426
  Makes use of Out-ColorMatchInfo found at http://poshcode.org/1095.
	Source: http://poshcode.org/1096
#>

#requires -version 2
param ( 
	[Parameter(Mandatory=$true)] 
	[regex] $pattern,
	[string] $filter = "*.*",
	[switch] $recurse = $true,
	[switch] $caseSensitive = $false,
	[int[]] $context = 0
)

if ((-not $caseSensitive) -and (-not $pattern.Options -match "IgnoreCase")) {
	$pattern = New-Object regex $pattern.ToString(),@($pattern.Options,"IgnoreCase")
}

Get-ChildItem -recurse:$recurse -filter:$filter |
	Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context | 
	Out-ColorMatchInfo
