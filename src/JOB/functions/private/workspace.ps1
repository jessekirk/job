function getworkspace
{
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param([parameter(ParameterSetName = 'workspace')][validateset('win10', 'win11')]$setos, [parameter(ParameterSetName = 'display')][switch]$display)

    switch ($PSCmdlet.ParameterSetName)
    {
        default
        {
            if (($xml.xml.win10.default -eq $true -and $xml.xml.win11.default -eq $true) -or ($xml.xml.win10.default -eq $false -and $xml.xml.win11.default -eq $false)) { throw 'Invalid JOB.xml configuration.' }
            if ($display.IsPresent) { return [pscustomobject]@{win10 = $xml.xml.win10.default ; win11 = $xml.xml.win11.default } }
        }
        'workspace'
        {
            if ($setos -eq 'win10') { $xml.xml.win10.default = 'true' ; $xml.xml.win11.default = 'false' } ; if ($setos -eq 'win11') { $xml.xml.win11.default = 'true' ; $xml.xml.win10.default = 'false' }
            try { $xml.Save($(Join-Path -Path $PSScriptRoot -ChildPath ../../config/JOB.xml)) } catch { 'Failed to save JOB.xml' ; return }
            Write-Host -Object "The JOB.xml file has been successfully updated for $setos." -ForegroundColor Cyan
        }
    }
}