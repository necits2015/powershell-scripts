# Check if C:\temp exists, if not create it
if(!(Test-Path -Path C:\temp )) {
    New-Item -ItemType directory -Path C:\temp
}

# Backup the registry key to C:\temp
try {
    Write-Output "Backing up registry key to C:\temp\RegistryBackup.reg..."
    Invoke-Expression -Command "reg export `"HKLM\System\CurrentControlSet\Services`" `"C:\temp\RegistryBackup.reg`""
    Write-Output "Backup of registry key successfully completed."
} catch {
    Write-Error "Failed to backup registry key. Error: $_"
    return
}

# Define service keys
$serviceKeys = 'HKLM:\System\CurrentControlSet\Services\*'

# Get services
try {
    Write-Output "Retrieving service information from registry..."
    $services = Get-ItemProperty -Path $serviceKeys 
    Write-Output "Service information successfully retrieved from the registry."
} catch {
    Write-Error "Failed to retrieve service information from the registry. Error: $_"
    return
}

# Loop through each service
foreach($service in $services) {
    # Check if the ImagePath key is set
    if($service.PSObject.Properties.Name -contains "ImagePath") {
        # Exclude services located in C:\Windows\, %SystemRoot%\, System32\, and \SystemRoot\, and \??\C:\WINDOWS
        if($service.ImagePath -notlike "C:\Windows\*" -and $service.ImagePath -notlike "%SystemRoot%\*" -and $service.ImagePath -notlike "*System32\*" -and $service.ImagePath -notlike "\SystemRoot\*" -and $service.ImagePath -notlike "\??\C:\WINDOWS*" -and !($service.ImagePath -match '^".*?"')) {
            # Check if the service is set to auto start
            if($service.Start -eq 2) {
                # Add quotes to the ImagePath up to .exe if it contains spaces and it's not already quoted
                $imagePath = $service.ImagePath
                if($imagePath -match '\s' -and $imagePath -notmatch '^".*\.exe"') {
                    # find the position of .exe in the string
                    $exePos = $imagePath.IndexOf(".exe")
                    if($exePos -gt 0) {
                        # insert the quote after .exe
                        $imagePath = $imagePath.Insert($exePos + 4, "`"")
                        # add the quote at the beginning of the string
                        $imagePath = "`"" + $imagePath
                    }

                    # Modify the ImagePath in the registry
                    try {
                        Set-ItemProperty -Path $service.PSPath -Name "ImagePath" -Value $imagePath
                        Write-Output "Successfully updated ImagePath for $($service.PSChildName) to $imagePath"
                    } catch {
                        Write-Error "Failed to update ImagePath for $($service.PSChildName). Error: $_"
                    }
                }
            }
        }
    }
}

Write-Output "Script execution completed."
