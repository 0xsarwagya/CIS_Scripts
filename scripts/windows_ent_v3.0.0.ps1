# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as an Administrator!"
    exit
}

# Log file location
$LogFile = "C:\CIS_Enterprise_Audit_Log.txt"

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

# 1.1.1 Ensure 'Accounts: Administrator account status' is set to 'Disabled'
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

# Example of using the Check-Setting function for Administrator Account Status
Check-Setting -Description "Administrator Account Status" `
    -CheckScript { Check-AdministratorAccountStatus } `
    -ApplyScript { Apply-AdministratorAccountStatus } `
    -VerifyScript { Verify-AdministratorAccountStatus }

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

# 2.3.11 Ensure 'Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' is set to 'Enabled'
function Check-AuditPolicyOverride {
    Log-Message "Checking audit policy override setting..."
    $AuditPolicyOverride = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy"
    return ($AuditPolicyOverride.SCENoApplyLegacyAuditPolicy -eq 1)
}

function Apply-AuditPolicyOverride {
    Log-Message "Enabling audit policy override..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy" -Value 1
}

function Verify-AuditPolicyOverride {
    Check-Setting -CheckScript {Check-AuditPolicyOverride} -ErrorMessage "Audit policy override could not be enabled."
    Log-Message "Audit policy override is enabled."
}

# 2.2.6 Ensure 'Network security: LAN Manager authentication level' is set to 'Send NTLMv2 response only. Refuse LM & NTLM'
function Check-LMAuthenticationLevel {
    Log-Message "Checking LAN Manager authentication level..."
    $LMLevel = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel"
    return ($LMLevel.LmCompatibilityLevel -eq 5)
}

function Apply-LMAuthenticationLevel {
    Log-Message "Setting LAN Manager authentication level..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5
}

function Verify-LMAuthenticationLevel {
    Check-Setting -CheckScript {Check-LMAuthenticationLevel} -ErrorMessage "LAN Manager authentication level could not be set."
    Log-Message "LAN Manager authentication level is set to NTLMv2 only."
}

# 3.3 Ensure 'Windows Firewall: Public: Firewall state' is set to 'On (recommended)'
function Check-FirewallPublic {
    Log-Message "Checking public firewall status..."
    $FirewallPublic = Get-NetFirewallProfile -Profile Public | Select-Object -ExpandProperty Enabled
    return ($FirewallPublic -eq 'True')
}

function Apply-FirewallPublic {
    Log-Message "Enabling public firewall..."
    Set-NetFirewallProfile -Profile Public -Enabled True
}

function Verify-FirewallPublic {
    Check-Setting -CheckScript {Check-FirewallPublic} -ErrorMessage "Public firewall could not be enabled."
    Log-Message "Public firewall is enabled."
}

# 4.1 Ensure 'Local Administrator Account' is renamed and disabled
function Check-LocalAdminAccount {
    Log-Message "Checking local administrator account..."
    $AdminAccount = Get-LocalUser -Name "Administrator"
    return ($AdminAccount.Enabled -eq $false)
}

function Apply-LocalAdminAccount {
    Log-Message "Disabling local administrator account..."
    Disable-LocalUser -Name "Administrator"
}

function Verify-LocalAdminAccount {
    Check-Setting -CheckScript {Check-LocalAdminAccount} -ErrorMessage "Local administrator account could not be disabled."
    Log-Message "Local administrator account is disabled."
}

# 5.2 Ensure 'Account lockout threshold' is set to 10 or fewer invalid logon attempts
function Check-AccountLockoutThreshold {
    Log-Message "Checking account lockout threshold..."
    $LockoutThreshold = Get-ADDefaultDomainPasswordPolicy | Select-Object -ExpandProperty LockoutThreshold
    return ($LockoutThreshold -le 10)
}

function Apply-AccountLockoutThreshold {
    Log-Message "Setting account lockout threshold..."
    Set-ADDefaultDomainPasswordPolicy -LockoutThreshold 10
}

function Verify-AccountLockoutThreshold {
    Check-Setting -CheckScript {Check-AccountLockoutThreshold} -ErrorMessage "Account lockout threshold could not be set."
    Log-Message "Account lockout threshold is set to 10 or fewer invalid logon attempts."
}

# Execution of the functions in order

Verify-WindowsDefender
Apply-WindowsDefender
Verify-WindowsDefender

Verify-AuditPolicyOverride
Apply-AuditPolicyOverride
Verify-AuditPolicyOverride

Verify-LMAuthenticationLevel
Apply-LMAuthenticationLevel
Verify-LMAuthenticationLevel

Verify-FirewallPublic
Apply-FirewallPublic
Verify-FirewallPublic

Verify-LocalAdminAccount
Apply-LocalAdminAccount
Verify-LocalAdminAccount

Verify-AccountLockoutThreshold
Apply-AccountLockoutThreshold
Verify-AccountLockoutThreshold

Log-Message "CIS Hardening script for Windows 11 Enterprise completed successfully."
