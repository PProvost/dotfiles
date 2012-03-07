param(
		$dest = $(throw "Usage: backup-profile <dest>")
)

# robocopy $env:USERPROFILE $dest /e /r:0 /w:0 /xj /l /log:$dest\backup-profile.log
robocopy $env:USERPROFILE $dest /e /r:0 /w:0 /xj /log:$dest\backup-profile.log
