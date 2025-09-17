---
title: "Linux Security Cheat Sheet"
date: 2025-09-17 16:00:00 +0800
categories: [linux, security, cheatsheet]
tags: [linux, sysadmin, hardening, firewall, monitoring]
excerpt: "A concise Linux security cheat sheet covering user management, SSH, firewall, updates, and monitoring."
author: Wrench L
image: /images/blog_images/linux-penguins.png
---

# Linux Security Cheat Sheet

---

## User & Account Management

- Add new user → `sudo adduser username`  
- Delete user → `sudo deluser username`  
- Add user to group → `sudo usermod -aG group username`  
- Check groups of a user → `groups username`  
- List all groups → `getent group`  
- Disable account → edit `/etc/passwd` → change shell to `/sbin/nologin`  
- Disable root login → set shell of root to `/sbin/nologin`  

<!-- IMAGE SPACE: user management diagram -->

---

## Password Policy

**Config files:**  
- Debian/Ubuntu → `/etc/pam.d/common-password`  
- RHEL/Fedora → `/etc/security/pwquality.conf`  

**Example options:**  
- `difok=5` → require 5 new different characters  
- `minlen=10` → minimum password length  
- `minclass=3` → must contain 3 character classes (upper, lower, digits, special)  
- `badwords=password123 secret root`  
- `retry=2` → retry attempts  

**Apply changes:** `sudo pam-auth-update`

<!-- IMAGE SPACE: password policy illustration -->

---

## SSH Security

- Generate SSH key pair → `ssh-keygen -t rsa`  
- Copy public key → `ssh-copy-id user@server`  
- SSH config → `/etc/ssh/sshd_config`  
  - `PubkeyAuthentication yes`  
  - `PasswordAuthentication no`  
- Restart SSH → `sudo systemctl restart ssh`  

<!-- IMAGE SPACE: SSH keys workflow -->

---

## Physical Security

- Defense-in-Depth: boot access = root access  
- Set BIOS/UEFI password  
- Set GRUB password:  
  - Generate → `grub2-mkpasswd-pbkdf2`  
  - Add hash to `/etc/grub.d/40_custom`  
- Cloud VMs → GRUB password not applicable  
- Encrypt disks with LUKS:  
  - Create → `cryptsetup luksFormat /dev/sdX`  
  - Open → `cryptsetup open /dev/sdX myvault`  
  - Mount → `mount /dev/mapper/myvault /mnt`  

<!-- IMAGE SPACE: LUKS encryption example -->

---

## Firewall Security

**Default backend:** Netfilter  
**Frontends:**  
- iptables (legacy)  
- nftables (modern)  
- ufw (Uncomplicated Firewall)  
- firewalld (RHEL-based)  

### iptables

- Allow SSH:  
  - `iptables -A INPUT -p tcp --dport 22 -j ACCEPT`  
  - `iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT`  
- Block all else:  
  - `iptables -A INPUT -j DROP`  
  - `iptables -A OUTPUT -j DROP`  
- Flush old rules → `iptables -F`  

### nftables

- Create table & chains:  
  - `nft add table fwfilter`  
  - `nft add chain fwfilter fwinput { type filter hook input priority 0 ; }`  
  - `nft add chain fwfilter fwoutput { type filter hook output priority 0 ; }`  
- Allow SSH:  
  - `nft add rule fwfilter fwinput tcp dport 22 accept`  
  - `nft add rule fwfilter fwoutput tcp sport 22 accept`  
- List rules: `nft list table fwfilter`  

### ufw (Uncomplicated Firewall)

- Allow SSH → `ufw allow 22/tcp`  
- Enable firewall → `ufw enable`  
- Check status → `ufw status`  

### Firewall Policy

- Default Approaches:  
  - Deny all, allow exceptions (more secure)  
  - Allow all, block exceptions (less secure)  
- Example: allow only DNS (53), HTTP (80), HTTPS (443)  

<!-- IMAGE SPACE: firewall diagram -->

---

## Reduce Attack Surface

- Disable unnecessary services → `systemctl disable service`  
- Remove unused packages → `apt remove pkg` or `yum remove pkg`  
- Block unused ports with firewall  
- Avoid legacy protocols:  
  - Replace Telnet → SSH  
  - Replace TFTP → SFTP  
- Remove server identification strings where possible  

---

## System Updates

- Debian/Ubuntu: `sudo apt update && sudo apt upgrade`  
- RedHat/Fedora:  
  - Older (RHEL7) → `yum update`  
  - Newer (RHEL8+, Fedora) → `dnf update`  
- Ubuntu LTS support: 5 years free + 5 years Extended Security Maintenance (ESM)  
- RedHat Enterprise Linux support: 5 years full + 5 years maintenance + 2 years extended  
- Kernel updates critical (e.g., Dirty COW vulnerability)  
- Enable automatic updates for security patches  

<!-- IMAGE SPACE: system updates illustration -->

---

## Logs & Monitoring

- Log directory → `/var/log`  
- Important logs:  
  - `/var/log/messages` → general  
  - `/var/log/auth.log` → authentication (Debian)  
  - `/var/log/secure` → authentication (RHEL/Fedora)  
  - `/var/log/utmp` → current logged in users  
  - `/var/log/wtmp` → all logins/logouts  
  - `/var/log/kern.log` → kernel messages  
  - `/var/log/boot.log` → startup logs  
- Useful commands:  
  - `tail -n 15 /var/log/kern.log` → last 15 lines  
  - `grep denied /var/log/secure` → search for “denied”  

<!-- IMAGE SPACE: logs and monitoring -->

---

## Common Questions

- Command to update older Red Hat → `yum update`  
- Command to update modern Fedora → `dnf update`  
- Update Debian system → `apt update && apt upgrade`  
- yum = Yellowdog Updater, Modified  
- dnf = Dandified YUM  

---

**Author:** wrench  
## Notes

- Always create non-root users for daily tasks to reduce the risk of system compromise.
- Disable unnecessary services to minimize the attack surface.
- Keep SSH access restricted with key-based authentication and disable password logins.
- Regularly apply system updates and kernel patches—critical for preventing exploitation of known vulnerabilities like Dirty COW.
- Use firewall rules (iptables, nftables, or ufw) to restrict unnecessary inbound/outbound traffic.
- Encrypt sensitive disks with LUKS to protect data at rest.
- Monitor logs frequently (`/var/log/auth.log`, `/var/log/secure`, `/var/log/kern.log`) to detect suspicious activity.
- Always verify the legitimacy of system processes and daemons when performing security audits.
- Document all changes and keep backups of critical configuration files before modifications.
- Cheat sheets are guides, not replacements for deep understanding of Linux security concepts.

---

## References

1. [Linux Documentation Project](https://www.tldp.org)
2. [Debian Admin Guide](https://www.debian.org/doc/manuals/debian-reference/)
3. [Red Hat Security Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
4. [Ubuntu Security Essentials](https://ubuntu.com/security)
5. [Arch Linux Security Tips](https://wiki.archlinux.org/title/Security)
6. [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
7. Practical Linux Security Cookbook – Packt Publishing
