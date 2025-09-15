# Enhanced scheduled task setup with validation and error handling
param(
    [string]$ScriptPath = "C:\powershell-script\log_meta.ps1",
    [string]$TaskName = "ReportDiskUsage",
    [string]$LogFile = "C:\Users\Administrator\Documents\task_setup_log.txt"
)

function Write-SetupLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue
    Write-Host $logEntry
}

try {
    Write-SetupLog "=== Starting enhanced scheduled task setup ==="
    
    # Validate script exists
    if (!(Test-Path $ScriptPath)) {
        throw "Script not found at: $ScriptPath"
    }
    Write-SetupLog "Script validated at: $ScriptPath"
    
    # Remove existing task if it exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-SetupLog "Removing existing task: $TaskName"
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Start-Sleep -Seconds 2
    }
    
    # Create enhanced PowerShell execution arguments
    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy Bypass"
        "-WindowStyle Hidden"
        "-File `"$ScriptPath`""
    ) -join " "
    
    Write-SetupLog "Using arguments: $arguments"
    
    # Define the action
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arguments
    
    # Define multiple triggers for reliability
    $triggerStartup = New-ScheduledTaskTrigger -AtStartup
    $triggerRepeating = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 9999)
    
    # Enhanced settings for reliability
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
                                           -DontStopIfGoingOnBatteries `
                                           -AllowStartIfOnBatteries `
                                           -DontStopOnIdleEnd `
                                           -ExecutionTimeLimit ([System.TimeSpan]::Zero) `
                                           -RestartCount 3 `
                                           -RestartInterval (New-TimeSpan -Minutes 5)
    
    # Set task principal for SYSTEM account with highest privileges
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Write-SetupLog "Registering scheduled task..."
    
    # Register the task
    $task = Register-ScheduledTask -TaskName $TaskName `
                                 -Description "Enhanced disk usage monitoring with error handling" `
                                 -Action $action `
                                 -Trigger $triggerStartup, $triggerRepeating `
                                 -Settings $settings `
                                 -Principal $principal `
                                 -Force
    
    if ($task) {
        Write-SetupLog "Task registered successfully"
        
        # Verify task registration
        $verifyTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($verifyTask) {
            Write-SetupLog "Task verification successful"
            Write-SetupLog "Task State: $($verifyTask.State)"
            
            # Start the task immediately for testing
            Write-SetupLog "Starting task for immediate test..."
            Start-ScheduledTask -TaskName $TaskName
            
            Start-Sleep -Seconds 5
            
            # Check task history
            $taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName
            Write-SetupLog "Last task result: $($taskInfo.LastTaskResult)"
            Write-SetupLog "Last run time: $($taskInfo.LastRunTime)"
            Write-SetupLog "Next run time: $($taskInfo.NextRunTime)"
            
        } else {
            throw "Task verification failed"
        }
    } else {
        throw "Failed to register scheduled task"
    }
    
    Write-SetupLog "=== Task setup completed successfully ==="
    
    # Display final status
    Write-Host "`n=== TASK SETUP SUMMARY ===" -ForegroundColor Green
    Write-Host "Task Name: $TaskName" -ForegroundColor Yellow
    Write-Host "Script Path: $ScriptPath" -ForegroundColor Yellow
    Write-Host "Status: Successfully created and started" -ForegroundColor Green
    Write-Host "Next Run: $($taskInfo.NextRunTime)" -ForegroundColor Yellow
    Write-Host "Check logs at: C:\Users\Administrator\Documents\error_log.txt" -ForegroundColor Yellow
    
}
catch {
    Write-SetupLog "CRITICAL ERROR: $($_.Exception.Message)" "ERROR"
    Write-SetupLog "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Host "Task setup failed. Check log file: $LogFile" -ForegroundColor Red
    exit 1
}
