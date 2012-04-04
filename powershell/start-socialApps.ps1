# How long to wait between program starts
$wait = 5

function fireItUp([string] $path) {
	$progName = [IO.Path]::GetFileNameWithouExtension($path)
	$proc = get-process -name $progName -errorAction SilentlyContinue
	if ($proc -eq $null) {
		& $path
	}
}

# Lync
& "C:\Program Files (x86)\Microsoft Lync\communicator.exe"
start-sleep $wait

# Live Messenger
& "C:\Program Files (x86)\Windows Live\Messenger\msnmsgr.exe"
start-sleep $wait

# TweetDeck
& "C:\Program Files (x86)\Twitter\TweetDeck\TweetDeck.exe"
start-sleep $wait

# Skype
& "C:\Program Files (x86)\Skype\Phone\Skype.exe"
start-sleep $wait
