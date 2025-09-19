$path = "C:\ProgramData\Cloudvantage"

# Remove inheritance and copy current rules
$acl.SetAccessRuleProtection($true, $true)

# Deny Users group Write + Delete permissions
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Users",
    "Write,CreateFiles,CreateDirectories,Delete,DeleteSubdirectoriesAndFiles",
    "ContainerInherit,ObjectInherit",
    "None",
    "Deny"
)

# Apply the rule
$acl.AddAccessRule($rule)

# Save it back
Set-Acl $path $acl

Write-Host "Read-only protection applied to $path for Users group."
