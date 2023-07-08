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
