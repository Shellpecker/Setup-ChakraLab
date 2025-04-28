[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Check .NET Framework 4.6+ installation
$netfxReleaseKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Release -ErrorAction SilentlyContinue

if ($netfxReleaseKey -lt 393295) {
    # .NET 4.6+ not installed
    Write-Host "[*] .NET Framework 4.6 or higher is required. Downloading and installing .NET Framework 4.8..." -ForegroundColor Yellow

    # Define download URL (official Microsoft .NET 4.8 offline installer)
    $downloadUrl = "https://go.microsoft.com/fwlink/?linkid=2088631"

    # Define download location
    $installerPath = "$env:TEMP\ndp48-x86-x64-allos-enu.exe"

    # Download the installer
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    Write-Host "[*] Download complete. Launching .NET Framework installer..." -ForegroundColor Green

    # Launch the installer (silent install)
    Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait

    Write-Host "[*] .NET Framework installation started. Please reboot the system after installation if required." -ForegroundColor Cyan

    exit 1
}


# Set variables
$buildToolsUrl = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
$installerPath = "$env:TEMP\vs_BuildTools.exe"
$installPath = "C:\BuildTools"


# Download the installer
Invoke-WebRequest -Uri $buildToolsUrl -OutFile $installerPath

# Run the installer silently with MSBuild and full C++ project system
Start-Process -FilePath $installerPath -ArgumentList `
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--installPath `"$installPath`"",
    "--add Microsoft.VisualStudio.Workload.MSBuildTools",
    "--add Microsoft.VisualStudio.Workload.VCTools",
    "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add Microsoft.VisualStudio.Component.VC.CoreBuildTools",
    "--add Microsoft.VisualStudio.Component.VC.ATL",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.19041" `
    -Wait -NoNewWindow

# Remove the installer after install
Remove-Item $installerPath -Force

# Locate MSBuild.exe
$msbuildPath = Get-ChildItem -Path "$installPath\MSBuild" -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*Current\Bin\MSBuild.exe" } |
    Select-Object -First 1 -ExpandProperty FullName

if ($msbuildPath) {
    $msbuildDir = Split-Path $msbuildPath

    # Read current system PATH
    $existingPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)

    # Only add if it's not already in PATH
    if ($existingPath -notlike "*$msbuildDir*") {
        $newPath = $existingPath + ";$msbuildDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
        Write-Host "✅ System PATH updated persistently with: $msbuildDir"
    } else {
        Write-Host "ℹ️ MSBuild path already in system PATH: $msbuildDir"
    }

    Write-Host "`n📍 MSBuild.exe found at: $msbuildPath"
    Write-Host "💡 You may need to restart your terminal or log off/log on to use it globally."
} 
else {
    Write-Host "❌ MSBuild.exe not found under $installPath. Please check the installation."
}
