function add-existingProject([string] $projFile) {
	$dte.Solution.AddFromFile($projFile, $false)
}

		
