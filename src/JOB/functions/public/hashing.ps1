function getsha256hash
{
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param([parameter(ParameterSetName = 'path')][string]$path)

    switch ($PSCmdlet.ParameterSetName)
    {
        default
        {
            (Get-ChildItem -Path $fullyqualifieddestinationpath -Recurse -File).FullName | ForEach-Object {
                Write-Verbose -Message "Hashing : $_ " -Verbose ; Get-FileHash -Path $_ -Algorithm SHA256 | ForEach-Object {
                    "$($_.hash.tolower())  $($_.path | Split-Path -Leaf)"
                }
            } | Out-File -FilePath $(Get-ChildItem -Path $fullyqualifieddestinationpath -Recurse -File -Filter '*.7z').FullName.Replace('.7z', '.7z.sha256.txt')
            Get-ChildItem -Path "$fullyqualifieddestinationpath\Release" -Recurse -Force | Unblock-File -Verbose ; rmupdates
        }
        'path'
        {
            (Get-ChildItem -Path $path -Recurse -File).FullName | ForEach-Object {
                Write-Verbose -Message "Hashing : $_ " -Verbose ; Get-FileHash -Path $_ -Algorithm SHA256 | ForEach-Object {
                    "$($_.hash.tolower())  $($_.path | Split-Path -Leaf)"
                }
            } | Out-File -FilePath $(Get-ChildItem -Path $path -Recurse -File -Filter '*.7z').FullName.Replace('.7z', '.7z.sha256.txt')
            Get-ChildItem -Path $path -Recurse -Force | Unblock-File -Verbose
        }
    }
}