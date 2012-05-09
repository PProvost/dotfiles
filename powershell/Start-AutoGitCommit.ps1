param(
	[string] $rootFolder = ".",
	[string] $filter = "*.*"
)

$path = resolve-path $rootFolder -errorAction Stop
write-host "Monitoring $path for changes"

$fsw = new-object System.IO.FileSystemWatcher $path, $filter
$fsw.IncludeSubdirectories = $true
$fsw.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'

$action = {
	$name = $event.SourceEventArgs.Name
	$changeType = $event.SourceEventArgs.ChangeType
	$timeStamp = $event.TimeGenerated

	write-host "The file '$name' was $changeType at $timeStamp" -fore green
}

register-objectEvent $fsw Created -SourceIdentifier FileCreated -Action $action
register-objectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action $action
register-objectEvent $fsw Changed -SourceIdentifier FileChanged -Action $action

# TODO: To disable this, call the following:
# unregister-event FileCreated
# unregister-event FileChanged
# unregister-event FileDeleted
