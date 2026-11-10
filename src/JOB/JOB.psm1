[xml]$script:xml = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath config/JOB.xml)
$script:json = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath config/applications.json) | ConvertFrom-Json




Export-ModuleMember -Function *