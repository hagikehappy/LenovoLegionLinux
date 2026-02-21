# Probe WMI for Lenovo Classes
# Run this in PowerShell as Administrator

Write-Host "Searching for Lenovo WMI classes..."
Write-Host "--------------------------------"

Get-WmiObject -Namespace root/wmi -List | Where-Object {$_.Name -like "*Lenovo*"} | ForEach-Object {
    Write-Host "Class Name: $($_.Name)"
    Write-Host "GUID:       $($_.Qualifiers['UUID'].Value)"

    $methods = $_.Methods
    if ($methods) {
        Write-Host "Methods:"
        foreach ($method in $methods) {
            Write-Host "  - $($method.Name)"
        }
    } else {
        Write-Host "Methods:    (None)"
    }
    Write-Host "--------------------------------"
}

Write-Host "Done."
