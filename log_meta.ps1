<#
.SYNOPSIS
  Fetches metadata from OpenStack metadata endpoint (if present), measures C: disk usage, and appends a JSON entry to a log file.

.NOTES
  - Default log: C:\Users\Administrator\Documents\log.json
  - Designed to be run interactively or from Task Scheduler.
#>

param(
    [string]$LogFile = "C:\Users\Administrator\Documents\log.json",
    [string]$MetaUrl = "http://169.254.169.254/openstack/latest/meta_data.json",
    [int]$HttpTimeoutSec = 5
)

try {
    # Ensure log directory exists
    $logDir = Split-Path -Parent $LogFile
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    # Attempt to fetch metadata (if not reachable, produce empty object)
    try {
        # Short timeout to avoid long waits if endpoint not present
        $webClientParams = @{ Uri = $MetaUrl; TimeoutSec = $HttpTimeoutSec; ErrorAction = 'Stop' }
        $meta = Invoke-RestMethod @webClientParams
    } catch {
        # Endpoint might not be available (not running on cloud). Use empty object.
        $meta = @{}
    }

    # Extract safe values (use empty string if not present)
    $serverId   = if ($null -ne $meta -and $meta.PSObject.Properties.Name -contains 'uuid') { $meta.uuid } else { "" }
    $projectId  = if ($null -ne $meta -and $meta.PSObject.Properties.Name -contains 'project_id') { $meta.project_id } else { "" }
    $cleanName  = if ($null -ne $meta -and $meta.PSObject.Properties.Name -contains 'name') { $meta.name } else { "" }

    # Get disk usage for C: (size - free); fallback to 0 if not found
    $diskUsage = 0
    try {
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
        if ($null -ne $disk -and $disk.Size -ne $null -and $disk.FreeSpace -ne $null) {
            # compute used bytes as 64-bit integer
            $size = [int64]$disk.Size
            $free = [int64]$disk.FreeSpace
            $used = $size - $free
            $diskUsage = if ($used -ge 0) { $used } else { 0 }
        }
    } catch {
        # If CIM fails (rare), keep diskUsage as 0
        $diskUsage = 0
    }

    # Timestamp
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

    # Build object
    $entry = [PSCustomObject]@{
        metadata = [PSCustomObject]@{
            server_id   = $serverId
            project_id  = $projectId
            server_name = $cleanName
        }
        timestamp  = $timestamp
        disk_usage = $diskUsage
    }

    # Convert to JSON and append to log file (one JSON object per append)
    $json = $entry | ConvertTo-Json -Depth 5

    # Append JSON + newline so each entry is separated
    Add-Content -Path $LogFile -Value $json -Encoding UTF8
    Add-Content -Path $LogFile -Value "" -Encoding UTF8  # newline separator

    # Optionally write to stdout so test runs show result
    Write-Output "Appended entry to $LogFile at $timestamp"
}
catch {
    # Top-level error: write to stderr and exit with non-zero code (useful for Task Scheduler)
    Write-Error "Failed to append metadata: $_"
    exit 1
}
# https://docs.google.com/document/d/1iSPzsgvv_dXSVlHTt7xZcJ9xDsp7LpC52dNwIJH7fFI/edit?usp=sharing
