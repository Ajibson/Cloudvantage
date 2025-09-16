# This is a Bootstrap script that retriggers the trigger.ps1 script every time the server is started
$taskName        = "BootstrapReportDiskUsage"
$taskDescription = "Perpetually logs disk usage to a file."
$executablePath  = "C:\ProgramData\Cloudvantage\trigger.ps1"
$taskUser        = "NT AUTHORITY\SYSTEM"

# Define the action
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
          -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$executablePath`""

# Trigger: at startup
$trigger = New-ScheduledTaskTrigger -AtStartup

# Settings: no time limit, start when available
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit ([System.TimeSpan]::Zero)

# (Re)register the task
Register-ScheduledTask -TaskName $taskName `
    -Description $taskDescription `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -User $taskUser `
    -RunLevel Highest `
    -Force

Write-Host "[$(Get-Date)] Task '$taskName' re-registered successfully."
