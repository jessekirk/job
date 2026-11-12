function testgitpath
{
    if ($xml.xml.win10.value -eq $true) { if ($script:gitpath = (Resolve-Path -Path $xml.xml.win10.git -ErrorAction SilentlyContinue).Path) { if ($null -ne $gitpath) { return } } }
    if ($xml.xml.win11.value -eq $true) { if ($script:gitpath = (Resolve-Path -Path $xml.xml.win11.git -ErrorAction SilentlyContinue).Path) { if ($null -ne $gitpath) { return } } }
    if (-not(Test-Path -Path "$gitpath\.git")) { throw 'This requires a Git repository. Verify path to only 1 valid repo.' }
}