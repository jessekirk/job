function newcmdfile
{
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param([parameter(ParameterSetName = 'script')][string]$powershellscript, [parameter(ParameterSetName = 'script')][switch]$noexit)

    switch ($PSCmdlet.ParameterSetName)
    {
        default
        {
            $fullyqualifiedcmdpath | Get-ChildItem -Recurse -Filter *.ps1 -Exclude 'apply_monthly_updates.ps1' | ForEach-Object {
                $path = $_.FullName | Split-Path -Parent
                $name = $_.Name.Replace('.ps1', '.cmd')
                $file = ($_.Name | Split-Path -Leaf).Replace('.ps1', $null)
                $value = @"
@echo off
setlocal enabledelayedexpansion
title %~n0
color 80
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    cls
    echo This file requires elevated administrator rights.
    echo Right-click on "%~nx0" and choose "Run as administrator".
    timeout /t -1
    exit /b
)
cls
pushd %~dp0
powershell.exe -nologo -file "%~dp0$($file).ps1"
"@ ; New-Item -Path $path -Name $name -ItemType File -Value $value -Force -Verbose | Out-Null
            }
        }
        'script'
        {
            if (-not($powershellscript.EndsWith('.ps1'))) { throw "The source PowerShell script $powershellscript does not have a '.ps1' extension." }
            if (-not(Test-Path -Path $powershellscript -ErrorAction SilentlyContinue)) { throw "The source PowerShell script $powershellscript does not exist." }
            $file = ($powershellscript | Split-Path -Leaf).Replace('.ps1', $null) ; $name = ($powershellscript | Split-Path -Leaf).Replace('.ps1', '.cmd')
            $value = @"
@echo off
setlocal enabledelayedexpansion
title %~n0
color 80
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    cls
    echo This file requires elevated administrator rights.
    echo Right-click on "%~nx0" and choose "Run as administrator".
    timeout /t -1
    exit /b
)
cls
pushd %~dp0
powershell.exe -nologo -file "%~dp0$($file).ps1"
"@  ; if ($noexit.IsPresent) { $value = $value -replace 'powershell.exe -nologo -file', 'powershell.exe -noexit -nologo -file' } ; New-Item -Path $($powershellscript | Split-Path -Parent) -Name $name -ItemType File -Value $value -Force -Verbose | Out-Null
        }
    }
}