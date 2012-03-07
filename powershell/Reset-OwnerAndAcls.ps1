# Use this script to "take control of" files that you can't access. Particularly
# useful for external NTFS volumes that were created on another computer or by
# another user

param(
		$filename = $(throw "Usage: take-control <file-or-dir name>")
)

takeown.exe /f $filename /r /d y
icacls.exe $filename /grant administrators:F /t
