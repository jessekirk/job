[xml]$script:xml = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath config/JOB.xml)
$script:json = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath config/applications.json) | ConvertFrom-Json
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath functions/public/*.ps1) -File | ForEach-Object { . $_.FullName }
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath functions/private/*.ps1) -File | ForEach-Object { . $_.FullName }
Export-ModuleMember -Function * -Variable fullyqualifieddestinationpath, gitpath, json, xml