# This is a script that triggers the log_meta.ps1 script to gather hard disk metrics every 5 minutes
$taskName        = "ReportDiskUsage"
$taskDescription = "Perpetually logs disk usage to a file."
$executablePath  = "C:\ProgramData\Cloudvantage\log_meta.ps1"
$taskUser        = "NT AUTHORITY\SYSTEM"

# Define the action to run the PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
          -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$executablePath`""

# Define triggers
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 9999)

# Define task settings: no execution time limit, start when available
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit ([System.TimeSpan]::Zero)

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName `
    -Description $taskDescription `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -User $taskUser `
    -RunLevel Highest `
    -Force

Write-Host "Scheduled task '$taskName' has been created successfully and will run every 1 minute after startup."
