function newpatchtuesdayfolder
{
    [cmdletbinding()]
    param([parameter(Mandatory)][string]$path, [parameter(ParameterSetName = 'month')][validateset('01-Jan', '02-Feb', '03-Mar', '04-Apr', '05-May', '06-Jun', '07-Jul', '08-Aug', '09-Sep', '10-Oct', '11-Nov', '12-Dec')]$month)

    switch ($PSCmdlet.ParameterSetName)
    {
        default
        {
            $d = Get-Date -Day 1 ; $first = $d ; while ($first.DayOfWeek -ne 'Tuesday') { $first = $first.AddDays(1) } ; $second = $first.AddDays(7) ; $yyyyMMdd = $second.ToString('yyyyMMdd')
        }
        'month'
        {
            $d = Get-Date -Month $($month.Remove(2)) -Day 1 ; $first = $d ; while ($first.DayOfWeek -ne 'Tuesday') { $first = $first.AddDays(1) } ; $second = $first.AddDays(7) ; $yyyyMMdd = $second.ToString('yyyyMMdd')
        }
    }

    if ($xml.xml.win10.value -eq $true -and $path -match $xml.xml.win10.majorVersion)
    {
        New-Item -Path "$path\Security Updates for Office 2016 x86_$($yyyyMMdd)" -ItemType Directory -Force -Verbose | Out-Null
        (Get-ChildItem -Path "$gitPath\monthly updates\_windows_updates" | Where-Object { $_.Name -match 'windows updates.ps1' }).FullName | Copy-Item -Destination "$($(Resolve-Path -Path "$path\Security Updates for Office 2016 x86*\").Path)" -Container -Force -Verbose
    }
    elseif ($xml.xml.win11.value -eq $true -and $path -match $xml.xml.win11.majorVersion)
    {
        New-Item -Path "$path\Security Updates for Windows 11 $($xml.xml.win11.windowsVersion)_$($yyyyMMdd)\Cumulative" -ItemType Directory -Force -Verbose | Out-Null
        New-Item -Path "$path\Security Updates for Office 2024 LTSC x64_$($yyyyMMdd)" -ItemType Directory -Force -Verbose | Out-Null
        New-Item -Path "$path\Security Definitions for Windows Defender AV_$($yyyyMMdd)\Latest" -ItemType Directory -Force -Verbose | Out-Null
        (Get-ChildItem -Path "$gitPath\monthly updates\_windows_updates" | Where-Object { $_.Name -match 'windows updates.ps1' }).FullName | Copy-Item -Destination "$($(Resolve-Path -Path "$path\Security Updates for Windows 11*\").Path)" -Container -Force -Verbose
        (Get-ChildItem -Path "$gitPath\monthly updates\_office_updates" | Where-Object { $_.Name -match 'office updates.ps1|office2024.xml' }).FullName | Copy-Item -Destination "$($(Resolve-Path -Path "$path\Security Updates for Office 2024 LTSC x64*\").Path)" -Container -Force -Verbose
        (Get-ChildItem -Path "$gitPath\monthly updates\_windefend" | Where-Object { $_.Name -match 'windows defender definitions.ps1' }).FullName | Copy-Item -Destination "$($(Resolve-Path -Path "$path\Security Definitions for Windows Defender AV*\").Path)" -Container -Force -Verbose
    }
    else { throw 'Invalid JOB.xml configuration.' }
}