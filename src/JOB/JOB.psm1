[xml]$script:xml = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath config/JOB.xml)

function getpublic { & (Join-Path -Path $PSScriptRoot -ChildPath public/echo.ps1) }
Export-ModuleMember -Function *