# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as an Administrator!"
    exit
}

# Log file location
$LogFile = "C:\CIS_Audit_Log.txt"

# Function to log messages
function Log-Message {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

# Function to check if a setting is compliant
function Check-Setting {
    param(
        [string]$Description,
        [scriptblock]$CheckScript,
        [scriptblock]$ApplyScript,
        [scriptblock]$VerifyScript
    )
    Log-Message "Checking $Description..."
    if (-not (& $CheckScript)) {
        Log-Message "Non-compliance detected for $Description. Applying fix..."
        & $ApplyScript
        if (& $VerifyScript) {
            Log-Message "$Description is now compliant."
        } else {
            Log-Message "ERROR: Failed to apply $Description."
        }
    } else {
        Log-Message "$Description is already compliant."
    }
}

# Example: 1.1.1 Ensure 'Accounts: Administrator account status' is set to 'Disabled'
function Check-AdministratorAccountStatus {
    $AdminAccount = Get-LocalUser -Name "Administrator"
    return ($AdminAccount.Enabled -eq $false)
}

function Apply-AdministratorAccountStatus {
    Disable-LocalUser -Name "Administrator"
}

function Verify-AdministratorAccountStatus {
    return (Get-LocalUser -Name "Administrator").Enabled -eq $false
}

# Example of using the Check-Setting function
Check-Setting -Description "Administrator Account Status" `
    -CheckScript { Check-AdministratorAccountStatus } `
    -ApplyScript { Apply-AdministratorAccountStatus } `
    -VerifyScript { Verify-AdministratorAccountStatus }

# Add similar blocks for each control listed in the CIS Benchmark document

# 1.1.2 Ensure 'Accounts: Guest account status' is set to 'Disabled'
function Check-GuestAccountStatus {
    $GuestAccount = Get-LocalUser -Name "Guest"
    return ($GuestAccount.Enabled -eq $false)
}

function Apply-GuestAccountStatus {
    Disable-LocalUser -Name "Guest"
}

function Verify-GuestAccountStatus {
    return (Get-LocalUser -Name "Guest").Enabled -eq $false
}

# Check, Apply, and Verify for Guest Account Status
Check-Setting -Description "Guest Account Status" `
    -CheckScript { Check-GuestAccountStatus } `
    -ApplyScript { Apply-GuestAccountStatus } `
    -VerifyScript { Verify-GuestAccountStatus }

# 1.2.1 Ensure 'Audit: Account Logon' is set to 'Success and Failure'
function Check-AuditAccountLogon {
    $AuditSettings = AuditPol /get /subcategory:"Account Logon" /category:"Logon/Logoff"
    return ($AuditSettings -match "Success and Failure")
}

function Apply-AuditAccountLogon {
    AuditPol /set /subcategory:"Account Logon" /success:enable /failure:enable
}

function Verify-AuditAccountLogon {
    $AuditSettings = AuditPol /get /subcategory:"Account Logon" /category:"Logon/Logoff"
    return ($AuditSettings -match "Success and Failure")
}

# Check, Apply, and Verify for Account Logon Audit Setting
Check-Setting -Description "Account Logon Audit Setting" `
    -CheckScript { Check-AuditAccountLogon } `
    -ApplyScript { Apply-AuditAccountLogon } `
    -VerifyScript { Verify-AuditAccountLogon }

# Repeat the above pattern for each CIS Benchmark control
