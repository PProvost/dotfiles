#
# Profile.ps1 - main powershell profile script
# 
# Applies to all hosts, so only put things here that are global
#


# If $home isn't set, set it to ~ 
# not sure this happens anymore, but what the hell
if (-not $global:home) { $global:home = (resolve-path ~) }

# Modules are stored here
$env:PSModulePath = "~/dotfiles/powershell/modules"

# Load in support modules
Import-Module "PowerTab" -ArgumentList "~\dotfiles\powershell\PowerTabConfig.xml"
Import-Module "Pscx"
Import-Module "Posh-Git"
Import-Module "Posh-Hg"
Import-Module "Posh-Svn"

# Path prepend/append helpers
# We'll make them global in case I want to use them interactively
function prepend-path([string] $path) { 
	if (-not [string]::IsNullOrEmpty($path)) {
		if ( (test-path $path) -and (-not $env.PATH.contains($path)) ) {
			$env:PATH = $path + ";" + $env:PATH;
		}
	}
	$env:PATH
}

function append-path([string] $path) { 
	if (-not [string]::IsNullOrEmpty($path)) {
		if ( (test-path $path) -and (-not $env.PATH.contains($path)) ) {
			$env:PATH += ";" + $path
		}
	}
	$env:PATH
}

# Some helpers for working with the filesystem
function remove-any([string] $glob) {
	remove-item -recurse -force $glob
}

function get-childfiles {
	get-childitem | ? { -not $_.PsIsContainer }
}

function get-childcontainers {
	get-childitem | ? { $_.PsIsContainer }
}

function get-currentDirectoryName {
	$path = ""
	$pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)
	if($pathbits.length -eq 1) {
		$path = $pathbits[0] + "\"
	} else {
		$path = $pathbits[$pathbits.length - 1]
	}
	$path
}


########################################################
# Custom 'cd' command to maintain directory history
#
# Usage:
#  cd					no args means cd $home
#  cd <name>	changes to that directory
#  cd -l			list your directory history
#  cd -#			change to the history entry specified by #
#
if( test-path alias:\cd ) { remove-item alias:\cd }
$global:PWD = get-location;
$global:CDHIST = [System.Collections.Arraylist]::Repeat($PWD, 1);
function cd {
	$cwd = get-location;
	$l = $global:CDHIST.count;

	if ($args.length -eq 0) { 
		set-location $HOME;
		$global:PWD = get-location;
		$global:CDHIST.Remove($global:PWD);
		if ($global:CDHIST[0] -ne $global:PWD) {
			$global:CDHIST.Insert(0,$global:PWD);
		}
		$global:PWD;
	}
	elseif ($args[0] -like "-[0-9]*") {
		$num = $args[0].Replace("-","");
		$global:PWD = $global:CDHIST[$num];
		set-location $global:PWD;
		$global:CDHIST.RemoveAt($num);
		$global:CDHIST.Insert(0,$global:PWD);
		$global:PWD;
	}
	elseif ($args[0] -eq "-l") {
		for ($i = $l-1; $i -ge 0 ; $i--) { 
			"{0,6}  {1}" -f $i, $global:CDHIST[$i];
		}
	}
	elseif ($args[0] -eq "-") { 
		if ($global:CDHIST.count -gt 1) {
			$t = $CDHIST[0];
			$CDHIST[0] = $CDHIST[1];
			$CDHIST[1] = $t;
			set-location $global:CDHIST[0];
			$global:PWD = get-location;
		}
		$global:PWD;
	}
	else { 
		set-location "$args";
	$global:PWD = pwd; 
		for ($i = ($l - 1); $i -ge 0; $i--) { 
			if ($global:PWD -eq $CDHIST[$i]) {
				$global:CDHIST.RemoveAt($i);
			}
		}

		$global:CDHIST.Insert(0,$global:PWD);
		$global:PWD;
	}

	$global:PWD = get-location;
}

function prompt {
	$nextId = (get-history -count 1).Id + 1;
	Write-Host "$($nextId): " -noNewLine

	# Figure out current directory name
	$currentDirectoryName = get-currentDirectoryName

	# Admin mode prompt?
	$wi = [System.Security.Principal.WindowsIdentity]::GetCurrent();
	$wp = new-object 'System.Security.Principal.WindowsPrincipal' $wi;
	$userLocation = $env:username + '@' + [System.Environment]::MachineName

	# Main prompt text
	if ( $wp.IsInRole("Administrators") -eq 1 ) {
		$color = "Red";
		$title = "**ADMIN** " + $currentDirectoryName
	} else {
		$color = "Green";
		$title = $currentDirectoryName
	}

	# Window title and main prompt text
	$host.UI.RawUi.WindowTitle = $title
	# Write-Host $userLocation -nonewline -foregroundcolor $color 
	Write-Host (" " + $currentDirectoryName) -nonewline
	
	# And finally whatever version control info we have
  Write-VcsStatus

	return "> "
}


# Global aliases
set-alias rmd remove-any
set-alias lsf get-childfiles
set-alias lsd get-childcontainers

