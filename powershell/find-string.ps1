$local:command_usage = "usage: find-string glob text"
if ($args.length -lt 2) { return ($command_usage) }
get-childitem -recurse -include $args[0] | select-string $args[1] | group-object Path | select-object @{Expression={ $_.Name.Substring((get-location).Path.Length + 1) }; Name="Filename" }, @{Expression={ $_.Group | foreach-object { $_.LineNumber} }; Name="Line Numbers"} | format-table -Autosize
