# ensure PowerShell uses TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# set up a clean path
$installer = Join-Path $env:TEMP 'NDP48-x86-x64-AllOS-ENU.exe'

# download directly from Microsoft’s CDN
Invoke-WebRequest `
  -Uri 'https://download.microsoft.com/download/f/3/a/f3a6af84-da23-40a5-8d1c-49cc10c8e76f/NDP48-x86-x64-AllOS-ENU.exe' `
  -OutFile $installer

# then kick off the silent install
Start-Process `
  -FilePath $installer `
  -ArgumentList '/quiet','/norestart' `
  -Wait
