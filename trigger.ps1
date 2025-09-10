$taskName = "ReportDiskUsage"
$taskDescription = "Perpetually logs disk usage to a file."
$executablePath = "C:\powershell-script\log_meta.ps1" # "C:\Users\Administrator\Documents\log_meta.ps1"
$taskUser = "NT AUTHORITY\SYSTEM"

# Define the action to run the PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$executablePath`""

# Define the trigger to run the task every minut
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)

# Define task settings, using a TimeSpan object for indefinite execution time
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit ([System.TimeSpan]::Zero)

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger $trigger -Settings $settings -User $taskUser -RunLevel Highest

Write-Host "Scheduled task '$taskName' has been created successfully."
