# Define variables
$meta        = Invoke-RestMethod -Uri http://169.254.169.254/openstack/latest/meta_data.json
$SERVER_ID   = $meta.uuid
$PROJECT_ID  = $meta.project_id
$CLEAN_NAME  = $meta.name
$DISK_USAGE  = (Get-PSDrive C).Used
$LOG_FILE    = "C:\log.txt"

# Create JSON object and store in file $LOG_FILE variable for debugging purpose
$data = @{
    metadata = @{
        server_id   = $SERVER_ID
        project_id  = $PROJECT_ID
        server_name = $CLEAN_NAME
    }
    disk_usage = $DISK_USAGE
}

# Convert to JSON and append to file for demo/debugging purpose
$json = $data | ConvertTo-Json -Depth 5
Add-Content -Path $LOG_FILE -Value $json -Encoding UTF8
Add-Content -Path $LOG_FILE -Value ""    # newline separator

# Send JSON data to cloudvantage monitoring endpoint
$body = @{
    server_id   = $SERVER_ID
    server_name = $CLEAN_NAME
    project_id  = $PROJECT_ID
    disk_usage  = $DISK_USAGE
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://cloudvantage-monitoring-endpoint.example.com/disk-report" `
                      -Method Post `
                      -ContentType "application/json" `
                      -Body $body
    Write-Host "Report successfully sent."
}
catch {
    Write-Host "Failed to send report: $($_.Exception.Message)"
}
