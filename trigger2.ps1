$taskName = "ReportDiskUsage" 
$taskDescription = "Perpetually logs disk usage to a file."
$executablePath = "C:\powershell-script\log_meta.ps1"
$taskUser = "NT AUTHORITY\SYSTEM"

# Define the action to run the PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$executablePath`""

# Define the trigger: run at startup, and repeat every 1 minute indefinitely
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Repetition = (New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)).Repetition

# Define task settings: no execution time limit, start when available
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit ([System.TimeSpan]::Zero)

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger $trigger -Settings $settings -User $taskUser -RunLevel Highest -Force

Write-Host "Scheduled task '$taskName' has been created successfully and will run every 1 minute after startup."
