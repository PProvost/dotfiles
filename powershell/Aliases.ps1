set-alias count measure-object
set-alias irssi start-irssi
set-alias lsd get-childcontainers
set-alias lsf get-childfiles
set-alias rmd remove-allChildItems
if (test-path alias:\set) { remove-item alias:\set -force }
set-alias set set-variableEx -force
set-alias sudo Invoke-Elevated
set-alias unset remove-variable

