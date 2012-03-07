#
# Profile.ps1 - main powershell profile script
# 
# Applies to all hosts, so only put things here that are global
#

# Setup the $home directory correctly
if (-not $global:home) { $global:home = (resolve-path ~) }

# And the scripts directory to wherever this file is located
$scripts = resolve-path ~/dotfiles/powershell

# Modules are stored here
$env:PSModulePath = join-path $scripts modules

# Load in support modules
Import-Module "Pscx" -Arg (join-path $scripts Pscx.UserPreferences.ps1)
Import-Module "PowerTab" -ArgumentList (join-path $scripts PowerTabConfig.xml)
Import-Module "Posh-Git"
Import-Module "Posh-Hg"
Import-Module "Posh-Svn"

# Some helpers for working with the filesystem
function remove-allChildItems([string] $glob) { remove-item -recurse -force $glob }
function get-childfiles { get-childitem | ? { -not $_.PsIsContainer } }
function get-childcontainers { get-childitem | ? { $_.PsIsContainer } }

# A "set" function that behaves more like the same
# command in cmd and bash.
function set-variableEx
{
	if ($args.Count -eq 0) { get-variable }
	elseif ($args.Count -eq 1) { get-variable $args[0] }
	else { invoke-expression "set-variable $args" }
}

# Vim-style shorten-path originally from Tomas Restrepo
# https://github.com/tomasr
function get-vimShortPath([string] $path) {
   $loc = $path.Replace($HOME, '~')
	 $loc = $loc.Replace($env:WINDIR, '[Windows]')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}

function get-isAdminUser() {
	$id = [Security.Principal.WindowsIdentity]::GetCurrent()
	$wp = new-object Security.Principal.WindowsPrincipal($id)
	return $wp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function prompt {
	# Colors
	$prefixColor = [ConsoleColor]::Cyan
	$pathColor = [ConsoleColor]::Cyan
	$pathBracesColor = [ConsoleColor]::DarkCyan
	$hostNameColor = ?: { get-isAdminUser } { [ConsoleColor]::Red } { [ConsoleColor]::Green }

	$prefix = [char]0x221e + " "
	$hostName = [net.dns]::GetHostName().ToLower()
	$shortPath = get-vimShortPath(get-location)

	write-host $prefix -noNewLine -foregroundColor $prefixColor
	write-host $hostName -noNewLine -foregroundColor $hostNameColor
	write-host ' {' -noNewLine -foregroundColor $pathBracesColor
	write-host $shortPath -noNewLine -foregroundColor $pathColor
	write-host '}' -noNewLine -foregroundColor $pathBracesColor
	write-vcsStatus # from posh-git, posh-hg and posh-svn
	return ' '
}

# UNIX friendly environment variables
$env:EDITOR = "gvim.exe"
$env:VISUAL = $env:EDITOR
$env:GIT_EDITOR = $env:EDITOR

# Global aliases
set-alias rmd remove-allChildItems
set-alias lsf get-childfiles
set-alias lsd get-childcontainers
set-alias count measure-object
if (test-path alias:\set) { remove-item alias:\set -force }
set-alias set set-variableEx -force
set-alias unset remove-variable

# Path tweaks
add-pathVariable $scripts
