# For generating a BBCode table
# get-addons | % { [string]::Format("|{0}|{1}|{2}|",$_.Name, $_.Notes, $_.Version) } | clip

function GetTocProperty( $dir, $prop )
{
	$tocFile = $dir.Name + ".toc"
	$path = join-path $dir.FullName $tocFile
	$match = "## " + $prop + ":*"
	$line = [string] $(gc $path | ? { $_ -like $match })
	if ($line.Length -gt $(4+$prop.Length))
	{
		return $line.Substring(4+$prop.Length).Trim()
	}
	else
	{
		return $line.Trim()
	}
}

function GetAddonObject( $dir )
{
	$addon = new-object PSObject
	add-member NoteProperty "Name" $dir.Name -inputObject $addon
	add-member NoteProperty "Path" $dir.FullName -inputObject $addon
	add-member NoteProperty "Author" $(GetTocProperty $dir "Author") -inputObject $addon
	add-member NoteProperty "Interface" $(GetTocProperty $dir "Interface") -inputObject $addon
	add-member NoteProperty "Version" $(GetTocProperty $dir "Version") -inputObject $addon
	add-member NoteProperty "Notes" $(GetTocProperty $dir "Notes") -inputObject $addon
	add-member NoteProperty "Dependencies" $(GetTocProperty $dir "Dependencies") -inputObject $addon
	add-member NoteProperty "OptionalDeps" $(GetTocProperty $dir "OptionalDeps") -inputObject $addon
	add-member NoteProperty "Category" $(GetTocProperty $dir "X-Category") -inputObject $addon
	return $addon
}

if (test-path "HKLM:\SOFTWARE\Wow6432Node\Blizzard Entertainment\World of Warcraft") {
	$wowDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Wow6432Node\Blizzard Entertainment\World of Warcraft").InstallPath;
} else {
	if (test-path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft") {
		$wowDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft").InstallPath;
	} else {
		$wowDir = "C:\Program Files\World of Warcraft\";
	}
}
$wowAddonDir = join-path $wowDir "Interface\Addons";

$list = new-object System.Collections.ArrayList
get-childitem $wowAddonDir | ? { ($_.PSIsContainer -eq $true) -and (-not $_.Name.StartsWith("Blizzard")) } | % {
	$addon = GetAddonObject $_
	$idx = $list.Add( $addon )
}
$list.ToArray()
