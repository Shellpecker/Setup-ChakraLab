# Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

# Variables
$commit      = "331aa3931ab69ca2bd64f7e020165e693b8030b5"
$repoName    = "ChakraCore"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$tempZip     = Join-Path $desktopPath "$repoName-$commit.zip"
$extractPath = Join-Path $desktopPath "$repoName-$commit"
$solutionPath = Join-Path $extractPath "ChakraCore.sln"

# Clean up any previous download/build on the Desktop
if (Test-Path $tempZip)       { Remove-Item $tempZip -Force }
if (Test-Path $extractPath)   { Remove-Item $extractPath -Recurse -Force }

# Step 1: Download the ZIP to your Desktop
Write-Host "[*] Downloading $repoName@$commit to Desktop..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/Microsoft/$repoName/archive/$commit.zip" -OutFile $tempZip

# Step 2: Extract it on the Desktop
Write-Host "[*] Extracting to Desktop..." -ForegroundColor Cyan
Expand-Archive -Path $tempZip -DestinationPath $desktopPath -Force

# Step 3: Find MSBuild
Write-Host "[*] Locating MSBuild.exe..." -ForegroundColor Cyan
$msbuild = Get-Command msbuild.exe -ErrorAction SilentlyContinue |
           Select-Object -ExpandProperty Source -First 1

if (-not $msbuild) {
    $possible = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    )
    foreach ($p in $possible) {
        if (Test-Path $p) { $msbuild = $p; break }
    }
}

if (-not $msbuild) {
    Write-Error "MSBuild.exe not found! Please install Visual Studio Build Tools with C++ components."
    exit 1
}

# Step 4: Build the solution in-place on the Desktop
Write-Host "[*] Building ChakraCore.sln (Debug, x64, CFG)..." -ForegroundColor Green
& $msbuild `
    "$solutionPath" `
    /p:Configuration=Debug `
    /p:Platform=x64 `
    /p:EnableControlFlowGuard=true `
    /m

Write-Host "[*] Build finished! Binaries are under $extractPath\bin\Debug\*" -ForegroundColor Green
