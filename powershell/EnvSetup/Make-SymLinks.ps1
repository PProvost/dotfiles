# new-symlink requires elevated privileges
invoke-elevated {
	Import-Module ..\Modules\Pscx
	new-junction ~\.vim ..\..\.vim
	new-junction ~\Documents\WindowsPowerShell ..\

	new-symlink ~\.vimrc ..\..\.vimrc
	new-symlink ~\.gitconfig ..\..\.gitconfig
	new-symlink ~\.gitignore ..\..\.gitignore
	new-symlink ~\.kdiff3rc ..\..\.kdiff3rc
}
