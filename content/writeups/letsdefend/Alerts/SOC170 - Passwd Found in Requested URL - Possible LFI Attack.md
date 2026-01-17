---
title: "LetsDefend SOC170 – Local File Inclusion (LFI) Attempt Analysis"
date: 2026-01-12
tags: ["letsdefend", "soc", "lfi", "web-attack", "directory-traversal", "blue"]
categories: ["SOC Writeups", "Web Security"]
draft: false
---


| Field                  | Value                                                                                                  |
| ---------------------- | ------------------------------------------------------------------------------------------------------ |
| Event ID               | 120                                                                                                    |
| Event Time             | Mar 01, 2022, 10:10 AM                                                                                 |
| Rule                   | SOC170 – Passwd Found in Requested URL – Possible LFI Attack                                           |
| Analyst Level          | Security Analyst                                                                                       |
| Hostname               | WebServer1006                                                                                          |
| Destination IP Address | 172.16.17.13                                                                                           |
| Source IP Address      | 106.55.45.162                                                                                          |
| HTTP Request Method    | GET                                                                                                    |
| Requested URL          | [https://172.16.17.13/?file=../../../../etc/passwd](https://172.16.17.13/?file=../../../../etc/passwd) |
| User-Agent             | Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)                                  |
| Alert Trigger Reason   | URL contains `passwd`                                                                                  |
| Device Action          | Allowed                                                                                                |


## Play Book

### 1. Alert Overview

A web attack alert was triggered on WebServer1006 due to the detection of a directory traversal payload attempting to access the sensitive system file /etc/passwd via an HTTP GET request. This behavior is commonly associated with Local File Inclusion (LFI) attacks, where an attacker attempts to read files from the underlying operating system through a vulnerable web application parameter.

The request originated from an external IP address and was allowed by the security device, which required further investigation to determine whether the attempt was successful or resulted in data exposure.

### 2. Key Event Details

| Field                  | Value                                                                 |
|------------------------|-----------------------------------------------------------------------|
| Hostname               | WebServer1006                                                         |
| Destination IP         | 172.16.17.13                                                          |
| Source IP              | 106.55.45.162                                                         |
| HTTP Method            | GET                                                                   |
| Requested URL          | https://172.16.17.13/?file=../../../../etc/passwd                     |
| User-Agent             | Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322) |
| Trigger Reason         | URL contains passwd                                                   |
| Device Action          | Allowed                                                               |

### 3. Why This Alert Was Triggered

The detection rule is designed to identify known LFI indicators within requested URLs. The presence of the directory traversal sequence (../../../../) combined with the target file /etc/passwd directly matches common LFI exploitation patterns.

Attackers frequently target /etc/passwd to enumerate system users and confirm whether file inclusion vulnerabilities are exploitable.

Based on the rule name and the request contents, this alert indicates an attempted LFI attack against a public-facing web application.

### 4. IP Reputation Check

The source IP address 106.55.45.162 is associated with Tencent Cloud Computing infrastructure located in China and is categorized as data center / web hosting traffic.


![](https://i.ibb.co/60VkyqJq/Pasted-image-20260113162808.png)

AbuseIPDB results:
- IP reported 3,455 times
- Confidence of abuse: 1%
- Commonly observed in automated scanning and probing activity
![](https://i.ibb.co/PsQ8jZxF/Pasted-image-20260113162914.png)

VirusTotal analysis:
- No strong malware verdicts
- IP categorized as suspicious infrastructure rather than a specific malware host

These findings suggest the IP is likely used for reconnaissance or automated attack activity rather than legitimate end-user traffic.

### 5. Initial Investigation and Traffic Analysis

- The traffic originated from an external public IP address.
- The request targeted an internal web server over HTTPS (port 443).
- The User-Agent string is outdated and commonly associated with automated tools and scanners.
- The HTTP response status was 500 Internal Server Error.
- The HTTP response size was 0 bytes.

The response status and size indicate that the requested file was not successfully read or returned to the attacker.

### 6. Log Review

Firewall Logs:
- Source Port: 49028
- Destination Port: 443
- Action: Permitted
- Payload matched known LFI directory traversal patterns
![](https://i.ibb.co/C3MDRSGr/Pasted-image-20260113163037.png)

Web Server Logs:
- No evidence of /etc/passwd contents being returned
- No abnormal response size observed
![](https://i.ibb.co/dRCqjtf/Pasted-image-20260113163524.png)

System Logs:
- No command execution history
- No unauthorized access or privilege escalation detected
- Confirms the request did not result in successful exploitation

### 7. Email and User Activity Review

- No internal maintenance, testing, or simulated attack activity was scheduled at the time of the alert.
- No user activity or email logs correlate with this request.

This confirms the traffic was externally generated and not related to legitimate internal activity.

### 8. MITRE ATT&CK Mapping

Tactic:
Initial Access

Technique:
T1190 – Exploit Public-Facing Application

Sub-Technique:
Local File Inclusion / Directory Traversal

### 9. Impact Assessment

- Attack type: Local File Inclusion attempt
- Exploitation success: No
- Data exposure: None observed
- System compromise: None
- Lateral movement: Not detected

This incident represents an attempted but unsuccessful exploitation.

### 10. Recommended Actions

1. Implement strict input validation for file parameters
2. Disable dynamic file inclusion where not required
3. Deploy WAF rules to block directory traversal patterns
4. Monitor for repeated attempts from the same source IP
5. Consider blocking the source IP if no business justification exists
6. Review application code for file handling vulnerabilities

### Final Verdict

True Positive – Attempted Web Attack

The alert represents a confirmed Local File Inclusion attempt originating from an external source. Although the attack was unsuccessful and resulted in no data exposure, it highlights a potential application weakness that should be addressed to prevent future exploitation.


### Analyst Note


The alert was triggered due to an HTTP GET request attempting to access the sensitive system file /etc/passwd using directory traversal sequences (../../../../). This pattern is a well-known indicator of a Local File Inclusion (LFI) attack, typically used by attackers to read system files and enumerate users on Linux-based servers.

The request originated from an external IP address associated with a cloud hosting provider, which is commonly observed in automated scanning and reconnaissance activities. The User-Agent string used in the request is outdated and frequently seen in scripted attack tools, further supporting the malicious nature of the traffic.

Log analysis shows that the request was allowed by the security device; however, the HTTP response returned a 500 Internal Server Error with a response size of 0 bytes. Web server and system logs confirm that no file contents were successfully accessed or returned, and there is no evidence of command execution, privilege escalation, or system compromise.

No internal user activity, maintenance window, or security testing was identified at the time of the alert. Email logs and authentication logs also show no correlation with legitimate activity.

Based on the analysis, this alert is classified as a true positive representing an attempted but unsuccessful Local File Inclusion attack. No impact to the system was observed, but the attempt highlights the need for stronger input validation and web application hardening to prevent future exploitation attempts.


#### Note
An external IP attempted to access the /etc/passwd file using directory traversal in the URL, which is a common Local File Inclusion (LFI) attack technique. The request was allowed but returned an HTTP 500 response with no data, and logs confirm that the attack was unsuccessful. No system compromise or data exposure was detected.
