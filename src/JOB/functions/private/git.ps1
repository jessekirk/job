function testgit
{
    if ($xml.xml.win10.default -eq $true) { $script:repository = (Resolve-Path -Path $xml.xml.win10.git -ErrorAction SilentlyContinue).Path }
    if ($xml.xml.win11.default -eq $true) { $script:repository = (Resolve-Path -Path $xml.xml.win11.git -ErrorAction SilentlyContinue).Path }
}