# This script gathers the used disk space (in bytes) and it uses the meta data to get the unique data of the server in 
# question and output it to the CVG monitoring endpoint.
# Define variables
$meta        = Invoke-RestMethod -Uri http://169.254.169.254/openstack/latest/meta_data.json
$SERVER_ID   = $meta.uuid
$PROJECT_ID  = $meta.project_id
$CLEAN_NAME  = $meta.name
# $DISK_USAGE  = (Get-PSDrive C).Used
$drive = Get-PSDrive C
$DISK_TOTAL = $drive.Used + $drive.Free
$DISK_USAGE = $drive.Used  
$DISK_FREE = $drive.Free

$MONITORING_ENDPOINT = "https://staging.cvgcoops.com.ng/api/v1/openstack/servers/metrics/window-disk-report"
$LOG_FILE    = "C:\Users\Administrator\Documents\log.txt"

# Create JSON object and store in file $LOG_FILE variable for debugging purpose
$data = @{
    metadata = @{
        server_id   = $SERVER_ID
        project_id  = $PROJECT_ID
        server_name = $CLEAN_NAME
    }
    disk_usage = $DISK_USAGE
    disk_total = $DISK_TOTAL    
    disk_free  = $DISK_FREE 
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
    disk_total  = $DISK_TOTAL    
    disk_free   = $DISK_FREE
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $MONITORING_ENDPOINT `
                      -Method Post `
                      -ContentType "application/json" `
                      -Body $body
    Write-Host "Report successfully sent."
}
catch {
    Write-Host "Failed to send report: $($_.Exception.Message)"
}
