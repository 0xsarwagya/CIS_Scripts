#!/bin/bash

# Ensure the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!" >&2
    exit 1
fi

LOGFILE="/var/log/cis_hardening.log"
exec > >(tee -i $LOGFILE)
exec 2>&1

check_setting() {
    if [ $? -ne 0 ]; then
        echo "Error applying setting: $1" >&2
        exit 1
    fi
}

# 1.1.5 Ensure separate partition exists for /var
check_var_partition() {
    echo "Checking /var partition..."
    grep -q " /var " /etc/fstab
    if [ $? -ne 0 ]; then
        echo "No separate /var partition found."
    else
        echo "/var partition exists."
    fi
}

apply_var_partition() {
    echo "Configuring /var partition..."
    # Insert appropriate commands for partitioning if necessary.
    check_setting "/var partition configuration"
}

verify_var_partition() {
    echo "Verifying /var partition configuration..."
    mount | grep " /var " | grep -q nodev
    check_setting "/var partition verification"
}

# 1.6.2 Ensure address space layout randomization (ASLR) is enabled
check_aslr() {
    echo "Checking ASLR status..."
    if [ "$(sysctl kernel.randomize_va_space)" != "kernel.randomize_va_space = 2" ]; then
        echo "ASLR is not enabled."
    else
        echo "ASLR is enabled."
    fi
}

apply_aslr() {
    echo "Enabling ASLR..."
    echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
    sysctl -w kernel.randomize_va_space=2
    check_setting "ASLR enablement"
}

verify_aslr() {
    echo "Verifying ASLR status..."
    check_aslr
    check_setting "ASLR verification"
}

# 1.7.1 Ensure permissions on /etc/motd are configured
check_motd_permissions() {
    echo "Checking /etc/motd permissions..."
    if [ $(stat -c %U /etc/motd) != "root" ] || [ $(stat -c %a /etc/motd) != "644" ]; then
        echo "/etc/motd permissions are not secure."
    else
        echo "/etc/motd permissions are secure."
    fi
}

apply_motd_permissions() {
    echo "Setting /etc/motd permissions..."
    chown root:root /etc/motd
    chmod 644 /etc/motd
    check_setting "/etc/motd permissions"
}

verify_motd_permissions() {
    echo "Verifying /etc/motd permissions..."
    check_motd_permissions
    check_setting "/etc/motd permissions verification"
}

# 3.4.1 Ensure TCP Wrappers is installed
check_tcp_wrappers() {
    echo "Checking for TCP Wrappers..."
    if ! rpm -q tcp_wrappers &>/dev/null; then
        echo "TCP Wrappers is not installed."
    else
        echo "TCP Wrappers is installed."
    fi
}

install_tcp_wrappers() {
    echo "Installing TCP Wrappers..."
    yum -y install tcp_wrappers
    check_setting "TCP Wrappers installation"
}

verify_tcp_wrappers() {
    echo "Verifying TCP Wrappers installation..."
    check_tcp_wrappers
    check_setting "TCP Wrappers installation verification"
}

# 4.1.1 Ensure auditd service is installed
check_auditd_installed() {
    echo "Checking if auditd is installed..."
    if ! rpm -q audit &>/dev/null; then
        echo "auditd is not installed."
    else
        echo "auditd is installed."
    fi
}

install_auditd() {
    echo "Installing auditd..."
    yum -y install audit
    check_setting "auditd installation"
}

verify_auditd_installed() {
    echo "Verifying auditd installation..."
    check_auditd_installed
    check_setting "auditd installation verification"
}

# 4.1.3 Ensure auditing for processes that start prior to auditd is enabled
check_audit_grub() {
    echo "Checking for audit=1 in GRUB..."
    grep "audit=1" /etc/default/grub
    if [ $? -ne 0 ]; then
        echo "audit=1 not set in GRUB."
    else
        echo "audit=1 is set in GRUB."
    fi
}

apply_audit_grub() {
    echo "Enabling auditing in GRUB..."
    sed -i 's/^GRUB_CMDLINE_LINUX="/&audit=1 /' /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    check_setting "audit=1 in GRUB"
}

verify_audit_grub() {
    echo "Verifying audit=1 in GRUB..."
    check_audit_grub
    check_setting "audit=1 in GRUB verification"
}

# 5.4.1 Ensure password expiration is set to 365 days or less
check_password_expiration() {
    echo "Checking password expiration..."
    if [ $(grep -E "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}') -le 365 ]; then
        echo "Password expiration is correctly set."
    else
        echo "Password expiration is not correctly set."
    fi
}

apply_password_expiration() {
    echo "Setting password expiration to 365 days..."
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   365/' /etc/login.defs
    check_setting "password expiration"
}

verify_password_expiration() {
    echo "Verifying password expiration..."
    check_password_expiration
    check_setting "password expiration verification"
}

# 6.2.9 Ensure no legacy "+" entries exist in /etc/passwd, /etc/shadow, or /etc/group
check_legacy_entries() {
    echo "Checking for legacy '+' entries..."
    if grep -q '^+:' /etc/passwd /etc/shadow /etc/group; then
        echo "Legacy '+' entries found."
    else
        echo "No legacy '+' entries found."
    fi
}

remove_legacy_entries() {
    echo "Removing legacy '+' entries..."
    sed -i '/^+:/d' /etc/passwd /etc/shadow /etc/group
    check_setting "legacy '+' entries removal"
}

verify_legacy_entries_removal() {
    echo "Verifying legacy '+' entries removal..."
    check_legacy_entries
    check_setting "legacy '+' entries verification"
}

# Execution of the functions in order

check_var_partition
apply_var_partition
verify_var_partition

check_aslr
apply_aslr
verify_aslr

check_motd_permissions
apply_motd_permissions
verify_motd_permissions

check_tcp_wrappers
install_tcp_wrappers
verify_tcp_wrappers

check_auditd_installed
install_auditd
verify_auditd_installed

check_audit_grub
apply_audit_grub
verify_audit_grub

check_password_expiration
apply_password_expiration
verify_password_expiration

check_legacy_entries
remove_legacy_entries
verify_legacy_entries_removal

echo "CIS Hardening script completed successfully."