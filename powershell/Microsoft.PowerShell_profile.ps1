# Profile setup for the console host shell
# Will not be loaded by other hosts (e.g. VS11 Package Manager)

# Set the shell background color


# Helper functions for user/computer session management
function invoke-userLogout { shutdown /l /t 0 }
function invoke-systemShutdown { shutdown /s /t 5 }
function invoke-systemReboot { shutdown /r /t 5 }
function invoke-systemSleep { RunDll32.exe PowrProf.dll,SetSuspendState }
function invoke-terminalLock { RunDll32.exe User32.dll,LockWorkStation }

# Aliases
set-alias logout invoke-userLogout
set-alias halt invoke-systemShutdown
set-alias restart invoke-systemReboot
if (test-path alias:\sleep) { remove-item alias:\sleep -force }
set-alias sleep invoke-systemSleep -force
set-alias lock invoke-terminalLock

# My PowerTab color theme
import-tabExpansionTheme -LiteralPath $scripts\TabExpansionTheme.csv
