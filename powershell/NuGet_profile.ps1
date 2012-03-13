$global:promptTheme = @{
	prefixColor = [ConsoleColor]::Blue
	pathColor = [ConsoleColor]::Blue
	pathBracesColor = [ConsoleColor]::DarkBlue
	hostNameColor = ?: { get-isAdminUser } { [ConsoleColor]::DarkRed } { [ConsoleColor]::DarkGreen }
}

function add-existingProject([string] $projFile) {
	$dte.Solution.AddFromFile($projFile, $false)
}

		
