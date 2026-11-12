$ProgressPreference = 'SilentlyContinue'

function get7zip
{
    param([switch]$displayversion)

    $w = Invoke-WebRequest -Uri $($json.applications | Where-Object { $_.name -eq '7-zip' } | Select-Object -ExpandProperty uri) -UseBasicParsing ; $links = $w.Links.href
    $latest = $links | Where-Object { $_ -match '/releases/tag/' } | Sort-Object -Descending | Select-Object -First 1 ; $latest = $latest.Remove(0, 1)
    $version = $latest | Split-Path -Leaf ; $urilocation = "https://github.com/$($latest.Replace('tag','download'))/7z$($version.Replace('.',$null))-x64.exe"
    if ($displayversion.IsPresent) { return Write-Host -Object "latest version : $version" -ForegroundColor Cyan }
    Write-Verbose -Message "verifiying url: $urilocation" -Verbose
    try { $w = Invoke-WebRequest -Uri $urilocation -UseBasicParsing -ErrorAction Stop } catch { Write-Host -Object 'invalid url!' -ForegroundColor Red ; return }
    if ($w.StatusCode -eq 200) { Write-Verbose -Message 'statuscode 200, OK.' -Verbose }
    $path = "$($HOME)\desktop\7-Zip v$version" ; New-Item -Path $path -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $filename = $urilocation | Split-Path -Leaf ; Write-Verbose -Message "Downloading $filename" -Verbose ; Start-Sleep -Milliseconds 250
    Start-BitsTransfer -Source $urilocation -Destination $path\$filename -TransferType Download ; Write-Host -Object "done! download completed for $filename" -ForegroundColor Cyan
}

function getedge
{
    param([switch]$displayversion)

    $i = Invoke-RestMethod -Uri $($json.applications | Where-Object { $_.name -eq 'edge' } | Select-Object -ExpandProperty uri)
    $version = $i | Where-Object { $_.product -eq 'stable' } | Select-Object -ExpandProperty releases | Select-Object | Where-Object { $_.platform -eq 'windows' -and $_.architecture -eq 'x64' } `
    | Select-Object -First 1 | Select-Object -ExpandProperty productversion
    $urilocation = $i | Where-Object { $_.product -eq 'stable' } | Select-Object -ExpandProperty releases | Select-Object | Where-Object { $_.platform -eq 'windows' -and $_.architecture -eq 'x64' } `
    | Select-Object -First 1 | Select-Object -ExpandProperty artifacts | Select-Object -ExpandProperty location
    if ($displayversion.IsPresent) { return Write-Host -Object "latest version : $version" -ForegroundColor Cyan }
    $path = Join-Path -Path $HOME -ChildPath "desktop/Microsoft Edge v$version" ; New-Item -Path $path -ItemType Directory | Out-Null
    $filename = $urilocation | Split-Path -Leaf ; Start-BitsTransfer -Source $urilocation -Destination (Join-Path -Path $path -ChildPath $filename) ; Write-Host -Object 'done!' -ForegroundColor Cyan
}

function getnppp
{
    param([switch]$displayversion)

    $w = Invoke-WebRequest -Uri $($json.applications | Where-Object { $_.name -eq 'nppp' } | Select-Object -ExpandProperty uri) -UseBasicParsing
    $links = $w.Links.href | Where-Object { $_ -match 'notepad-plus-plus.org' }
    $latest = $links | Select-Object -First 1 ; $w = Invoke-WebRequest -Uri $latest -UseBasicParsing
    $fileversion = [version]($latest | Split-Path -Leaf).Remove(0, 1)

    if ($displayversion.IsPresent) { return Write-Host -Object "latest version : $($latest | Split-Path -Leaf)" -ForegroundColor Cyan }
    if ($xml.xml.win10.default -eq $true)
    {
        $urilocation = $w.Links.href | Where-Object { $_ -match 'installer.x64.exe' -and $_ -notmatch 'installer.x64.exe.sig' }
        if ($urilocation.Count -gt 1) { $urilocation = $urilocation | Sort-Object -Descending | Select-Object -First 1 }
        $path = "$($HOME)\desktop" ; $filename = $urilocation | Split-Path -Leaf
        Write-Verbose -Message "downloading $filename..." -Verbose ; Start-Sleep -Milliseconds 250
        Start-BitsTransfer -Source $urilocation -Destination $path\$filename -TransferType Download ; Start-Sleep -Milliseconds 250
        $name = "Notepad++ v$fileversion" ; New-Item -Path $path\$name -ItemType Directory -Force -Verbose | Out-Null
        Move-Item -Path $path\$filename -Destination $path\$name -Force -Verbose ; Write-Host -Object 'done!' -ForegroundColor Cyan ; return
    }

    $urilocation = $w.Links.href | Where-Object { $_ -match 'portable.x64.zip' -and $_ -notmatch 'portable.x64.zip.sig' }
    $path = "$($HOME)\desktop" ; $filename = $urilocation | Split-Path -Leaf ; Write-Verbose -Message "downloading $filename..." -Verbose ; Start-Sleep -Milliseconds 250
    Start-BitsTransfer -Source $urilocation -Destination $path\$filename -TransferType Download ; Start-Sleep -Milliseconds 250 ; $npp = $filename

    $w = Invoke-WebRequest -Uri $($json.applications | Where-Object { $_.name -eq 'nppp_compareplus' } | Select-Object -ExpandProperty uri) -UseBasicParsing
    $links = $w.Links.href
    $latest = $links | Where-Object { $_ -match '/tag/cp' } | Sort-Object -Descending | Select-Object -First 1 ; $latest = $latest.Remove(0, 1)
    $version = $latest | Split-Path -Leaf ; $urilocation = "https://github.com/$($latest.Replace('tag','download'))/ComparePlus_$($version)_x64.zip"
    Write-Verbose -Message "verifiying url: $urilocation" -Verbose
    try { $w = Invoke-WebRequest -Uri $urilocation -UseBasicParsing -ErrorAction Stop } catch { Write-Host -Object 'invalid url!' -ForegroundColor Red ; return }
    if ($w.StatusCode -eq 200) { Write-Verbose -Message 'statuscode 200, OK.' -Verbose }
    $filename = $version.ToString() + '.zip' ; $filenamecpp = $filename ; Write-Verbose -Message "downloading $filename..." -Verbose ; Start-Sleep -Milliseconds 250 ; Start-BitsTransfer -Source $urilocation -Destination $path\$filename -TransferType Download

    Write-Host -Object "building package for $npp..." -ForegroundColor Cyan ; Start-Sleep -Milliseconds 250
    $path = (Resolve-Path -Path "$path\npp*portable*x64*.zip").Path ; $filename = $path | Split-Path -Leaf ; $path = $path | Split-Path -Parent
    $leaf = "$($filename.Replace('.zip', $null)).w.compare.plus"
    Expand-Archive -Path $path\$filename -DestinationPath $path\$leaf -Force -Verbose ; Remove-Item -Path $path\$filename -Force -Verbose
    New-Item -Path "$path\$leaf\plugins" -Name 'ComparePlus' -ItemType Directory -Force -Verbose | Out-Null
    Expand-Archive -Path $path\$filenamecpp -DestinationPath "$path\$leaf\plugins\ComparePlus" -Force -Verbose ; Remove-Item -Path $path\$filenamecpp -Force -Verbose
    Compress-Archive -Path $path\$leaf\* -DestinationPath "$path\$leaf.zip" -CompressionLevel Optimal -Force -Verbose
    Write-Host -Object "done! $leaf compressed." -ForegroundColor Cyan
    $name = "Notepad++ v$fileversion" ; New-Item -Path $path -Name $name -ItemType Directory -Force -Verbose | Out-Null ; Move-Item -Path "$path\$leaf.zip" -Destination $path\$name -Force -Verbose
    Remove-Item -Path $path\$leaf -Recurse -Force -Verbose ; Write-Host -Object 'done!' -ForegroundColor Cyan
}

function getdefenderdefinitions
{
    # Requires manual check & download of file
    # Update for Microsoft Defender Antivirus antimalware platform - KB4052623 - Current Channel (Broad) Url : https://www.catalog.update.microsoft.com/Search.aspx?q=KB4052623

    param([parameter(Mandatory)][string]$destination)

    $leaf = $destination | Split-Path -Leaf ; if ($leaf -ne 'latest') { throw "Invalid destination path : $destination." }
    $path = $destination; $uri = $($json.applications | Where-Object { $_.name -eq 'defender_nis' } | Select-Object -ExpandProperty uri) # Network Real-time Inspection definitions | nis_full.exe
    $filename = 'nis_full.exe' ; Write-Verbose -Message "Downloading $filename..." -Verbose
    Start-BitsTransfer -Source $uri -Destination $(Join-Path -Path $path -ChildPath $filename) -TransferType Download ; Write-Host -Object "done! downloaded $filename to $path." -ForegroundColor Cyan
    $uri = $($json.applications | Where-Object { $_.name -eq 'defender_mpamfe' } | Select-Object -ExpandProperty uri) # Definitions | mpam-fe.exe
    $filename = 'mpam-fe.exe' ; Write-Verbose -Message "Downloading $filename..." -Verbose
    Start-BitsTransfer -Source $uri -Destination $(Join-Path -Path $path -ChildPath $filename) -TransferType Download ; Write-Host -Object "done! downloaded $filename to $path." -ForegroundColor Cyan
}