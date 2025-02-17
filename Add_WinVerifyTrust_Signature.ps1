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

# Define the paths
$path1 = "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config"
$path2 = "HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config"

# Define the key and value
$key = "EnableCertPaddingCheck"
$value = "1"

# Create a function for adding or setting the values
Function AddOrUpdate-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [Object]$Value
    )
    try {
        if(!(Test-Path -Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
        Write-Host "Registry key and value have been successfully added or updated at $Path."
    } catch {
        Write-Host ("Error occurred while adding or updating registry key at " + $Path + ": ") -NoNewline
        Write-Host $_.Exception.Message
    }
}

# Add or set the values
AddOrUpdate-RegistryValue -Path $path1 -Name $key -Value $value
AddOrUpdate-RegistryValue -Path $path2 -Name $key -Value $value
