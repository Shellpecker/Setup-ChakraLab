```
$global:progressPreference = 'silentlyContinue'
powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13;iex(Invoke-RestMethod 'https://raw.githubusercontent.com/Shellpecker/Setup-ChakraLab/refs/heads/main/Install-BuildTools.ps1')"
powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13;iex(Invoke-RestMethod 'https://raw.githubusercontent.com/Shellpecker/Setup-ChakraLab/refs/heads/main/Install-WinDbg.ps1')"
```
