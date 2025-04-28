[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12



$Arch = "x64"
$OutDir = "C:\Program Files (x86)"
if (!(Test-Path $OutDir)) {
    $null = mkdir $OutDir
}

# Download the appinstaller to find the current uri for the msixbundle
Invoke-WebRequest https://aka.ms/windbg/download -OutFile $OutDir\windbg.appinstaller

# Download the msixbundle
$msixBundleUri = ([xml](Get-Content $OutDir\windbg.appinstaller)).AppInstaller.MainBundle.Uri

if ($PSVersionTable.PSVersion.Major -lt 6) {
    # This is a workaround to get better performance on older versions of PowerShell
    $ProgressPreference = 'SilentlyContinue'
}

# Download the msixbundle (but name as zip for older versions of Expand-Archive
Invoke-WebRequest $msixBundleUri -OutFile $OutDir\windbg.zip

# Extract the 3 msix files (plus other files)
Expand-Archive -DestinationPath $OutDir\UnzippedBundle $OutDir\windbg.zip

# Expand the build you want - also renaming the msix to zip for Windows PowerShell
$fileName = switch ($Arch) {
    "x64" { "windbg_win-x64" }
    "x86" { "windbg_win-x86" }
    "arm64" { "windbg_win-arm64" }
}

# Rename msix (for older versions of Expand-Archive) and extract the debugger
Rename-Item "$OutDir\UnzippedBundle\$fileName.msix" "$fileName.zip"
Expand-Archive -DestinationPath "$OutDir\windbg" "$OutDir\UnzippedBundle\$fileName.zip"

# Path to the executable
$windbgExe = Join-Path "$OutDir\windbg" "DbgX.Shell.exe"

# Create a Desktop shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$Shortcut = $WScriptShell.CreateShortcut("$DesktopPath\WinDbg Preview.lnk")
$Shortcut.TargetPath = $windbgExe
$Shortcut.IconLocation = $windbgExe
$Shortcut.Save()
