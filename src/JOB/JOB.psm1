$xmlpath = Join-Path -Path $env:APPDATA -ChildPath JOB ; $script:xmlfile = Join-Path -Path $xmlpath -ChildPath JOB.xml
if (-not(Test-Path -Path $xmlpath))
{
    if (-not(Test-Path -Path $xmlfile)) { New-Item -Path $xmlpath -ItemType Directory | Out-Null } ; Copy-Item -Path $(Join-Path -Path $PSScriptRoot -ChildPath config/JOB.xml) -Destination $xmlpath -Container
}
[xml]$script:xml = Get-Content -Path $xmlfile -Raw
$script:json = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath config/applications.json) | ConvertFrom-Json
if ($xml.xml.win10.default -eq $true) { $script:repository = (Resolve-Path -Path $xml.xml.win10.repository -ErrorAction SilentlyContinue).Path }
if ($xml.xml.win11.default -eq $true) { $script:repository = (Resolve-Path -Path $xml.xml.win11.repository -ErrorAction SilentlyContinue).Path }
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath functions/public/*.ps1) -File | ForEach-Object { . $_.FullName }
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath functions/private/*.ps1) -File | ForEach-Object { . $_.FullName }
Export-ModuleMember -Function * -Variable fullyqualifieddestinationpath, repository, json, xml, xmlfile