# TODO:
#  - Change Omen default profile in Omen.lua
#

# WoW Location
$wowDir = "C:\Program Files\World of Warcraft";
if (test-path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft")
{
	$wowDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft").InstallPath;
}

# Some temp vars
$tmp = ''
$interfaceDir = join-path $wowDir "Interface"
$addonDir = join-path $interfaceDir "Addons";
$wtfDir = join-path $wowDir "WTF"
$accountDir = join-path $wtfDir "Account\PPROVOST"
$fontsDir = join-path $wowDir "Fonts"
$charDir = join-path $accountDir "Dragonblight\Quaiche"

# Create a staging dir
$stagingDir = join-path $wowDir "QBertUI"
if (test-path $stagingDir) {
	write-host -foregroundColor red "Removing existing staging directory!"
	remove-item -recurse -force $stagingDir
}
write-host -foregroundColor yellow "Creating staging directory '$stagingDir'"
$tmp = new-item -type directory -path $stagingDir -errorAction Stop

# Copy Fonts
write-host -foregroundColor yellow "Copying Fonts directory to staging directory"
copy-item -path $fontsDir -destination $stagingDir -recurse -force

# Copy Interface folder to the staging directory
write-host -foregroundColor yellow "Copying Interface directory to staging directory (may take a long time)"
copy-item -path $interfaceDir -destination $stagingDir -recurse -force 
$newAddonDir = "$stagingDir\Interface\Addons"

# Copy WTF\Account\PPROVOST folder to the staging directory in pieces
write-host -foregroundColor yellow "Creating new WTF directory"
$newWTF = join-path $stagingDir "WTF"
$tmp = new-item -type directory -path $newWTF
$newWtfAccount = join-path $newWTF "Account"
$tmp = new-item -type directory -path $newWtfAccount 

$newAccountDir = join-path $newWtfAccount "ACCOUNT_NAME"
$tmp = new-item -type directory -path $newAccountDir
get-childitem $accountDir | ? { -not $_.PSIsContainer -and -not $_.Name.EndsWith(".lua.bak") } | copy-item -destination $newAccountDir
$tmp = new-item -type directory -path $newAccountDir\SavedVariables
get-childitem $accountDir\SavedVariables\*.lua | copy-item -destination $newAccountDir\SavedVariables

$newCharNameDir = join-path $newAccountDir 'REALM_NAME\CHAR_NAME'
$tmp = new-item -type directory -path $newCharNameDir
get-childitem $charDir | ? { -not $_.PSIsContainer -and -not $_.Name.EndsWith(".lua.bak") } | copy-item -destination $newCharNameDir

$tmp = new-item -type directory -path $newCharNameDir\SavedVariables
get-childitem $charDir\SavedVariables\*.lua | copy-item -destination $newCharNameDir\SavedVariables

# Remove all PSUpdateAddons.state files
get-childitem -recurse -force "$newAddonDir\*" | ? { $_.Name -eq "PSUpdateAddons.state" } | remove-item -force

# Delete a addons we don't need to ship
remove-item -recurse -force "$newAddonDir\GuildRaidSnapShot"
get-childitem "$newAddonDir\Blizzard_*" | remove-item -recurse -force

# Delete a few character specific files that we don't wanna ship
remove-item -path "$newCharNameDir\SavedVariables\Assessment.lua"
remove-item -path "$newCharNameDir\SavedVariables\FuBar_HeyFu.lua"
remove-item -path "$newCharNameDir\SavedVariables\Cellular.lua"
remove-item -path "$newCharNameDir\SavedVariables\ClosetGnome.lua"
remove-item -path "$newCharNameDir\SavedVariables\FuBar_TopScoreFu.lua"
remove-item -path "$newCharNameDir\SavedVariables\Cartographer_Quests.lua"
remove-item -path "$newCharNameDir\SavedVariables\FuBar_MoneyFu.lua"
remove-item -path "$newCharNameDir\SavedVariables\FuBar_HonorFu.lua"

# And a few global SVs we don't need
remove-item -path "$newAccountDir\SavedVariables\Auc-ScanData.lua"
remote-item -path "$newAccountDir\SavedVariables\AuldLangSyne.lua"
remote-item -path "$newAccountDir\SavedVariables\AutoText.lua"
remove-item -path "$newAccountDir\SavedVariables\Baggins_AnywhereBags.lua"
remove-item -path "$newAccountDir\SavedVariables\BeanCounter.lua"
remove-item -path "$newAccountDir\SavedVariables\BulkMail2.lua"
remove-item -path "$newAccountDir\SavedVariables\CraftList2.lua"
remote-item -path "$newAccountDir\SavedVariables\FriendsWithBenefits.lua"
remove-item -path "$newAccountDir\SavedVariables\FuBar_GarbageFu.lua"
remove-item -path "$newAccountDir\SavedVariables\FuBar_MoneyFu.lua"
remove-item -path "$newAccountDir\SavedVariables\FuBar_tcgTradeskills.lua"
remove-item -path "$newAccountDir\SavedVariables\GuildRaidSnapShot.lua"
remove-item -path "$newAccountDir\SavedVariables\ItemValue.lua"
remove-item -path "$newAccountDir\SavedVariables\MoWater.lua"
remove-item -path "$newAccountDir\SavedVariables\Omnibus.lua"
remove-item -path "$newAccountDir\SavedVariables\OneView.lua"
remove-item -path "$newAccountDir\SavedVariables\Prat.lua"
remove-item -path "$newAccountDir\SavedVariables\Skillet.lua"

# And a couple more
remove-item -path "$newCharNameDir\chat-cache.txt"
remove-item -path "$newCharNameDir\camera-settings.txt"
remove-item -path "$newCharNameDir\macros-cache.txt"
remove-item -path "$newCharNameDir\macros-local.txt"

# Copy over the readme file
copy-item "$wowDir\QBERT UI README.txt" $stagingDir

write-host -foregroundColor green "DONE! Zip it and ship it!"

