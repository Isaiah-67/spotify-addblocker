# Ignore errors from `Stop-Process`
$PSDefaultParameterValues['Stop-Process:ErrorAction'] = 'SilentlyContinue'

write-host @'
***************** 
Fade#2046
#FadeIsAss
***************** 
'@

write-host @'
***************** 
Author: Isaiah
***************** 
'@

$SpotifyDirectory = "$env:APPDATA\Spotify"
$SpotifyExecutable = "$SpotifyDirectory\Spotify.exe"
$SpotifyApps = "$SpotifyDirectory\Apps"

Write-Host 'Stopping Spotify...'`n
Stop-Process -Name Spotify
Stop-Process -Name SpotifyWebHelper

if ($PSVersionTable.PSVersion.Major -ge 7)
{
    Import-Module Appx -UseWindowsPowerShell
}

if (Get-AppxPackage -Name SpotifyAB.SpotifyMusic) {
  Write-Host @'
The Microsoft Store version of Spotify has been detected which is not supported.
'@`n


     Write-Host @'
Uninstalling Spotify.
'@`n
     Get-AppxPackage -Name SpotifyAB.SpotifyMusic | Remove-AppxPackage


Push-Location -LiteralPath $env:TEMP
try {
  # Unique directory name based on time
  New-Item -Type Directory -Name "BlockTheSpot-$(Get-Date -UFormat '%Y-%m-%d_%H-%M-%S')" `
  | Convert-Path `
  | Set-Location
} catch {
  Write-Output $_
  Pause
  exit
}

Write-Host 'Downloading latest patch (chrome_elf.zip)...'`n
$webClient = New-Object -TypeName System.Net.WebClient
try {
  $webClient.DownloadFile(
    # Remote file URL
    'https://github.com/mrpond/BlockTheSpot/releases/latest/download/chrome_elf.zip',
    # Local file path
    "$PWD\chrome_elf.zip"
  )
} catch {
  Write-Output $_
  Sleep
}
<#
try {
  $webClient.DownloadFile(
    # Remote file URL
    'https://github.com/mrpond/BlockTheSpot/files/5969916/zlink.zip',
    # Local file path
    "$PWD\zlink.zip"
  )
} catch {
  Write-Output $_
  Sleep
}
try {
  $webClient.DownloadFile(
    # Remote file URL
    'https://github.com/mrpond/BlockTheSpot/files/6234124/xpui.zip',
    # Local file path
    "$PWD\xpui.zip"
  )
} catch {
  Write-Output $_
  Sleep
}
#>
Expand-Archive -Force -LiteralPath "$PWD\chrome_elf.zip" -DestinationPath $PWD
Remove-Item -LiteralPath "$PWD\chrome_elf.zip"
<#
Expand-Archive -Force -LiteralPath "$PWD\zlink.zip" -DestinationPath $PWD
Remove-Item -LiteralPath "$PWD\zlink.zip"
Expand-Archive -Force -LiteralPath "$PWD\xpui.zip" -DestinationPath $PWD
Remove-Item -LiteralPath "$PWD\xpui.zip"
#>
$spotifyInstalled = (Test-Path -LiteralPath $SpotifyExecutable)
$update = $false
if ($spotifyInstalled) {
  $ch = Read-Host -Prompt "Optional - Update Spotify to the latest version. (Might already be updated). (Y/N) "
  if ($ch -eq 'y') {
	$update = $true
  } else {
    Write-Host @'
Won't try to update Spotify.
'@
  }
} else {
  Write-Host @'
Spotify installation was not detected.
'@
}
if (-not $spotifyInstalled -or $update) {
  Write-Host @'
Downloading Latest Spotify full setup, please wait...
'@
  try {
    $webClient.DownloadFile(
      # Remote file URL
      'https://download.scdn.co/SpotifyFullSetup.exe',
      # Local file path
      "$PWD\SpotifyFullSetup.exe"
    )
  } catch {
    Write-Output $_
    Pause
    exit
  }
  mkdir $SpotifyDirectory >$null 2>&1
  Write-Host 'Running installation...'
  Start-Process -FilePath "$PWD\SpotifyFullSetup.exe"
  Write-Host 'Stopping Spotify...Again'
  while ((Get-Process -name Spotify -ErrorAction SilentlyContinue) -eq $null){
     #waiting until installation complete
     }
  Stop-Process -Name Spotify >$null 2>&1
  Stop-Process -Name SpotifyWebHelper >$null 2>&1
  Stop-Process -Name SpotifyFullSetup >$null 2>&1
}

if (!(test-path $SpotifyDirectory/chrome_elf_bak.dll)){
	move $SpotifyDirectory\chrome_elf.dll $SpotifyDirectory\chrome_elf_bak.dll >$null 2>&1
}

Write-Host 'Patching Spotify...'
$patchFiles = "$PWD\chrome_elf.dll", "$PWD\config.ini"
<#
$remup = "$PWD\zlink.spa"
$uipat = "$PWD\xpui.spa"
#>
Copy-Item -LiteralPath $patchFiles -Destination "$SpotifyDirectory"
<#


{
    $xpuiBundlePath = "$SpotifyApps\xpui.spa"
    $xpuiUnpackedPath = "$SpotifyApps\xpui\xpui.js"
    $fromZip = $false
    
    # Try to read xpui.js from xpui.spa for normal Spotify installations, or
    # directly from Apps/xpui/xpui.js in case Spicetify is installed.
    if (Test-Path $xpuiBundlePath) {
        Add-Type -Assembly 'System.IO.Compression.FileSystem'
        Copy-Item -Path $xpuiBundlePath -Destination "$xpuiBundlePath.bak"

        $zip = [System.IO.Compression.ZipFile]::Open($xpuiBundlePath, 'update')
        $entry = $zip.GetEntry('xpui.js')

        # Extract xpui.js from zip to memory
        $reader = New-Object System.IO.StreamReader($entry.Open())
        $xpuiContents = $reader.ReadToEnd()
        $reader.Close()

        $fromZip = $true
    } elseif (Test-Path $xpuiUnpackedPath) {
        Copy-Item -Path $xpuiUnpackedPath -Destination "$xpuiUnpackedPath.bak"
        $xpuiContents = Get-Content -Path $xpuiUnpackedPath -Raw

        Write-Host 'Spicetify detected - You may need to reinstall BTS after running "spicetify apply".';
}


$tempDirectory = $PWD
Pop-Location

Remove-Item -Recurse -LiteralPath $tempDirectory  

Write-Host 'Patching Complete, starting Spotify...'
Start-Process -WorkingDirectory $SpotifyDirectory -FilePath $SpotifyExecutable
Write-Host 'Done.'

write-host @'
***************** 
Fade#2046
#FadeIsAss
***************** 
'@

exit
