# Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Variables
$commit = "331aa3931ab69ca2bd64f7e020165e693b8030b5"
$repoName = "ChakraCore"
$zipUrl = "https://github.com/Microsoft/$repoName/archive/$commit.zip"
$tempZip = "$env:TEMP\$repoName-$commit.zip"
$extractPath = "$env:TEMP\$repoName-$commit"
$solutionPath = Join-Path $extractPath "ChakraCore.sln"

# Step 1: Download the ZIP
Write-Host "[*] Downloading ChakraCore at commit $commit..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip

# Step 2: Extract the ZIP
Write-Host "[*] Extracting..." -ForegroundColor Cyan
Expand-Archive -Path $tempZip -DestinationPath $env:TEMP -Force

# Step 3: Find MSBuild
Write-Host "[*] Locating MSBuild..." -ForegroundColor Cyan
$msbuild = Get-Command msbuild.exe -ErrorAction SilentlyContinue

if (!$msbuild) {
    # Try default Visual Studio paths
    $possibleMsbuildPaths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    )
    foreach ($path in $possibleMsbuildPaths) {
        if (Test-Path $path) {
            $msbuild = $path
            break
        }
    }
}

if (!$msbuild) {
    Write-Error "MSBuild.exe not found! Please install Visual Studio Build Tools with C++ components."
    exit 1
}

# Step 4: Build the solution
Write-Host "[*] Building ChakraCore.sln in Debug|x64 mode with CFG enabled..." -ForegroundColor Green

Start-Process -FilePath $msbuild -ArgumentList @(
    "`"$solutionPath`"",
    "/p:Configuration=Debug",
    "/p:Platform=x64",
    "/p:EnableControlFlowGuard=true",
    "/m"   # Build with multiple cores
) -NoNewWindow -Wait

Write-Host "[*] Build finished!" -ForegroundColor Green
