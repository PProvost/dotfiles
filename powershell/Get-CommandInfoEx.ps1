#
# Find out where/what kind of command "cmdname" is...
#

$local:whence_usage = 
"usage: which [-v] [-a] [-e extension] cmdname
  -v - verbose - show search progress in window title
  -a - search for all possible matches, not just the first
  -h - show this help text
  -e - look for a particular extension
  "
$local:basename = ""
$local:all = 0
$local:verbose = 0
$local:name = ""
$local:result = @()
$local:extensions = @()

#
# Crack the args...
#

if ($args.length -lt 1) { return ($whence_usage) }
foreach ($arg in $args) {
	switch -regex ($arg) {
		{ $doExt } { $extensions += ".$_",""; $doExt=0; continue }
		"^-a" { $all = 1 ; continue }
		"^[-/](h|help)" { return ($whence_usage) }
		"^-v" { $verbose = 1 ; continue }
		"^-e" { $doExt=1 ; continue }
		"^-e" {
			if ($foreach.movenext()) {
				$extensions += ("."+$foreach.current),""
			} else {
				return "error: -e requires an argument"
			}
			continue }
		"^-." { return "bad argument: $arg`n$whence_usage" }
		"^[^-]" { $basename = $arg ; continue}
	}
}

# make sure a name was actually requested...
if (! $basename ) {
	return ("You must specify a name to search for`n$whence_usage")
}

# Check to see if it's an alias
if (test-path "alias:$basename") {
	"alias $basename " + $(get-alias $basename).Definition
	if (! $all) {
		return
	}
}

# now see if it's a function
if (test-path "function:$basename") {
	"function $basename"
	if (! $all) {
		return
	}
}

# now see if it's a cmdlet
if ( get-command -type cmdlet $basename -ea silentlycontinue )
{
    "Cmdlet $basename"
}

# finally search the file system...

# if an extensions wasn't specified, search the path using all possible
# extensions...
if (! $extensions) {
	$extensions = @(".ps1");
	$extensions += $ENV:PATHEXT.Split(";");
}

foreach ($ext in $extensions) {
	foreach ($path  in $ENV:PATH.Split(";") ) {
		$name = "${path}\${basename}${ext}"
		$name = $name.Replace("`"", "")
		if ($verbose) {
			write-host "Checking  $name"
		}
		if (test-path $name) {
			$name
			if (! $all) {
				return
			}
		}
	}
}
