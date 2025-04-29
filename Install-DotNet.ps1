$netfxInstaller = "$env:TEMP\ndp48-x86-x64-allos-enu.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=840938" -OutFile $netfxInstaller
Start-Process -FilePath $netfxInstaller -ArgumentList "/quiet", "/norestart" -Wait
