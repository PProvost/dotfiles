$global:promptTheme = @{
	prefixColor = [ConsoleColor]::Blue
	pathColor = [ConsoleColor]::Blue
	pathBracesColor = [ConsoleColor]::DarkBlue
	hostNameColor = ?: { get-isAdminUser } { [ConsoleColor]::DarkRed } { [ConsoleColor]::DarkGreen }
}

$GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::Gray
$GitPromptSettings.AfterForegroundColor = [ConsoleColor]::Gray
$GitPromptSettings.BranchForegroundColor = [ConsoleColor]::DarkYellow

function add-existingProject([string] $projFile) {
	$dte.Solution.AddFromFile($projFile, $false)
}

		
