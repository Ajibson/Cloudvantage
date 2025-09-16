# Windows hard disk monitoring script
Cloud init script to:
install git
run git
clone this repository
save it in the C:\ProgramData\Cloudvantage\ dir 
run the trigger.ps1 and bootstrap.ps1

#cloud-config
runcmd:
  - powershell.exe -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; curl.exe -L -o C:\Git-Setup.exe https://github.com/git-for-windows/git/releases/download/v2.51.0.windows.1/Git-2.51.0-64-bit.exe; Start-Process -FilePath C:\Git-Setup.exe -ArgumentList '/VERYSILENT' -Wait; Remove-Item C:\Git-Setup.exe -Force; Start-Sleep -Seconds 10; & 'C:\Program Files\Git\bin\git.exe' clone https://github.com/feyilasisi/Cloudvantage.git C:\ProgramData\Cloudvantage; cd C:\ProgramData\Cloudvantage; .\trigger; .\bootstrap"
