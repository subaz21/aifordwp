param([string]$RegistrationToken)
$ErrorActionPreference = "Stop"
New-Item -Path "C:\Temp\AVD" -ItemType Directory -Force | Out-Null
Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" -OutFile "C:\Temp\AVD\AVDAgent.msi"
Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" -OutFile "C:\Temp\AVD\AVDBootloader.msi"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"C:\Temp\AVD\AVDAgent.msi`" /qn /norestart REGISTRATIONTOKEN=$RegistrationToken" -Wait -NoNewWindow
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"C:\Temp\AVD\AVDBootloader.msi`" /qn /norestart" -Wait -NoNewWindow
Get-Service -Name RDAgentBootLoader,RdAgent | Select-Object Name,Status,StartType
