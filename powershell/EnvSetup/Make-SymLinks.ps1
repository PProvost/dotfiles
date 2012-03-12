param(
	[switch] $WhatIf=$false
)

#########################################################################
# Check to make sure the environment is sane before doing anything
#

$errorColor = [ConsoleColor]::Red
$informationColor = [ConsoleColor]::White
$successColor = [ConsoleColor]::Green

function success-message([string] $message) {
	write-host "GOOD: " -noNewLine -foregroundColor $successColor
	write-host $message
}

function error-message([string] $message) {
	write-host "ERROR: " -noNewLine -foregroundColor $errorColor
	write-host $message
}

trap [Exception] {
	error-message "Unexpected error occurred. $_"
	exit 1
}

write-host "---------------------------------------------------"
write-host " Make-SymLinks.ps1 - Creates links and junctions"
write-host " for my dotfiles setup."
write-host "---------------------------------------------------"

# Figure out what directory the script is in
if (test-path variable:\hostinvocation) {
	$scriptLocation=$hostinvocation.MyCommand.Path
}	else {
	$scriptLocation=(get-variable myinvocation -scope script).value.Mycommand.Definition
}	
if (-not (test-path $scriptLocation)) {
	error-message "Unable to determine script path. Aborting."
	exit 3
}
success-message "Make-Symlinks.ps1 running from $scriptLocation"

# Figure out where the $scripts directory is
# and confirm that the profile.ps1 script is there
$sourcePowershellDirectory = split-path (split-path $scriptLocation) | resolve-path
$sourceProfilePath = join-path $sourcePowershellDirectory "profile.ps1"
if ((test-path $sourceProfilePath) -eq $false) {
	error-message "profile.ps1 not found in $sourcePowershellDirectory. Aborting."
	exit 3
}
success-message "Source profile.ps1 found at $(split-path $sourceProfilePath)"

$sourceDotfilesDirectory = split-path $sourcePowershellDirectory
success-message "Source dotfiles found at $sourceDotfilesDirectory"

# Make sure the source .vimrc exists and is a file
$sourceVimrcPath = join-path $sourceDotfilesDirectory ".vimrc" | resolve-path
if ((test-path -pathType Leaf $sourceVimrcPath) -eq $false) {
	error-message "Source $sourceVimrcPath does not exist or is not a file. Aborting"
	exit 1
}
success-message "Source .vimrc found at $sourceVimrcPath"

# Make sure the source .vim exists and is a directory
$sourceVimDirectory = join-path $sourceDotfilesDirectory ".vim" | resolve-path
if ((test-path -pathType Container $sourceVimDirectory) -eq $false) {
	error-message "Source $sourceVimDirectory does not exist or is not a directory. Aborting."
	exit 1
}
success-message "Source .vim directory found at $sourceVimDirectory"

# Make sure the source .gitconfig exists and is a file
$sourceGitconfigPath = join-path $sourceDotfilesDirectory ".gitconfig" | resolve-path
if ((test-path -pathType Leaf $sourceGitconfigPath) -eq $false) {
	error-message "Source $sourceGitconfigPath does not exist or is not a file. Aborting"
	exit 1
}
success-message "Source .gitconfig found at $sourceGitconfigPath"

# Make sure the source .gitconfig exists and is a file
$sourceGitignorePath = join-path $sourceDotfilesDirectory ".gitignore" | resolve-path
if ((test-path -pathType Leaf $sourceGitignorePath) -eq $false) {
	error-message "Source $sourceGitignorePath does not exist or is not a file. Aborting"
	exit 1
}
success-message "Source .gitignore found at $sourceGitignorePath"

# Check to see if the WindowsPowerShell profile directory already exists
$targetProfileDirectory = split-path $profile
if (test-path $targetProfileDirectory) {
	error-message "Directory $targetProfileDirectory already exists. Aborting."
	exit 1
}
success-message "Target PowerShell profile directory {$targetProfileDirectory} does not exist."

# Make sure target .vimrc doesn't exist
$targetVimrcPath = "~\.vimrc"
if (test-path $targetVimrcPath) {
	error-message "Target $targetVimrcPath exists. Aborting."
	exit 1
}
success-message "Target $targetVimrcPath does not exist."

$targetVimfilesDirectory = "~\.vim"
if (test-path $targetVimfilesDirectory) {
	error-message "Target $targetVimfilesDirectory exists. Aborting"
	exit 1
}
success-message "Target $targetVimfilesDirectory does not exist."

$targetGitconfigPath = "~\.gitconfig"
if (test-path $targetGitconfigPath) {
	error-message "Target $targetGitconfigPath exists. Aborting".
	exit 1
}
success-message "Target $targetGitconfigPath does not exist."

$targetGitignorePath = "~\.gitignore"
if (test-path $targetGitignorePath) {
	error-message "Target $targetGitignorePath exists. Aborting".
	exit 1
}
success-message "Target $targetGitignorePath does not exist."

#########################################################################
# Tell the user that we think we're ready to go
# and give them a chance to cancel
write-host "---------------------------------------------------"
write-host "Your system appears to be ready to go."
write-host "Press Ctrl+C to abort or any other key to continue."
write-host "---------------------------------------------------"
$key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp")

# Source in profile.ps1
# This should load in PSCX and all that other stuff
. $sourceProfilePath

# Ensure that PSCX loaded correctly
if ((get-module -name PSCX) -eq $null) {
	write-host "Module PSCX failed to load. Aborting." -foregroundColor $errorColor
	exit 3
}

#########################################################################
# Create all the links and whatnot

write-host "Creating hard link from $targetVimrcPath to $sourceVimrcPath" -foregroundColor $informationColor
if ($WhatIf -eq $true) {
	write-host ">> new-hardlink $targetVimrcPath $sourceVimrcPath"
} else {
	new-hardlink $targetVimrcPath $sourceVimrcPath
}

write-host "Creating junction point from $targetVimfilesDirectory to $sourceVimDirectory" -foregroundColor $informationColor
if ($WhatIf -eq $true) {
	write-host ">> new-junction $targetVimfilesDirectory $sourceVimDirectory"
} else {
	new-junction $targetVimfilesDirectory $sourceVimDirectory
}

write-host "Creating junction point from $targetProfileDirectory to $sourcePowershellDirectory"
if ($WhatIf -eq $true) {
	write-host ">> new-junction $targetProfileDirectory $sourcePowershellDirectory"
} else {
	new-junction "$targetProfileDirectory" $sourcePowershellDirectory
}

write-host "Creating hard link from $targetGitconfigPath to $sourceGitconfigPath"
if ($WhatIf -eq $true) {
	write-host ">> new-hardlink $targetGitconfigPath $sourceGitconfigPath"
} else {
	new-hardlink $targetGitconfigPath $sourceGitconfigPath
}

write-host "Creating hard link from $targetGitignorePath to $sourceGitignorePath"
if ($WhatIf -eq $true) {
	write-host ">> new-hardlink $targetGitignorePath $sourceGitignorePath"
} else {
	new-hardlink $targetGitignorePath $sourceGitignorePath
}

