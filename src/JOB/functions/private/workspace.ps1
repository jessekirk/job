function getworkspace
{
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param([parameter(ParameterSetName = 'setworkspace')][validateset('win10', 'win11')]$setworkspace, [parameter(ParameterSetName = 'display')][switch]$display)

    switch ($PSCmdlet.ParameterSetName)
    {
        default
        {
            if (($xml.xml.win10.default -eq $true -and $xml.xml.win11.default -eq $true) -or ($xml.xml.win10.default -eq $false -and $xml.xml.win11.default -eq $false)) { throw "Invalid configuration at : $xmlfile." }
            if ($display.IsPresent) { return [pscustomobject]@{win10 = $xml.xml.win10.default ; win11 = $xml.xml.win11.default } }
        }
        'setworkspace'
        {
            if ($setworkspace -eq 'win10') { $xml.xml.win10.default = 'true' ; $xml.xml.win11.default = 'false' } ; if ($setworkspace -eq 'win11') { $xml.xml.win11.default = 'true' ; $xml.xml.win10.default = 'false' }
            try { $xml.Save($xmlfile) } catch { "Failed to save : $xmlfile" ; return }
            Write-Host -Object "$xmlfile has been successfully updated for $setworkspace." -ForegroundColor Cyan
        }
    }
}