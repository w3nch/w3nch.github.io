---
title: "LetsDefend SOC168 – Command Injection (whoami) Web Attack Analysis"
date: 2026-01-13
tags: ["letsdefend", "soc", "blue", "web-attack", "command-injection", "http"]
categories: ["SOC Writeups", "Web Security"]
draft: false
---

**Alert Name:** SOC168 – Whoami Command Detected in Request Body  
**Severity:** High  
**Event ID:** 118  
**Event Time:** Feb 28, 2022, 04:12 AM  
**Category:** Web Attack
## Play Book
### 1. Alert Overview

A high-severity web attack alert was triggered on **WebServer1004** due to the detection of the `whoami` command within the HTTP request body. This behavior is commonly associated with **command injection attempts**, where an attacker tries to execute system-level commands through a web application.

The request originated from an external IP address and was allowed by the device, which increases the risk level of this incident.
### 2. Key Event Details
| Field          | Value                                                      |
| -------------- | ---------------------------------------------------------- |
| Hostname       | WebServer1004                                              |
| Destination IP | 172.16.17.16                                               |
| Source IP      | 61.177.172.87                                              |
| HTTP Method    | POST                                                       |
| Requested URL  | [https://172.16.17.16/video/](https://172.16.17.16/video/) |
| User-Agent     | Mozilla/4.0 (MSIE 6.0; Windows NT 5.1)                     |
| Trigger Reason | Request body contains `whoami` string                      |
| Device Action  | Allowed                                                    |

### 3. Why This Alert Was Triggered

The detection rule is designed to identify OS command execution patterns inside HTTP request bodies. The `whoami` command is frequently used by attackers to verify successful command execution and identify the privilege level of the exploited process.

Based on the rule name and request contents, this alert indicates a command injection attempt against a web application endpoint.

### 4. Ip reputation check 

The IP appears to be coming from china with domain register chinatelecom.com.cn attackers are using a 3rd party service to look ligit 
![](https://i.ibb.co/tMSBSshj/image1.png)

Searching on virus total only 2 vendors marked it as malware and suspicious not much. Checking the community tab looks like this ip ahas been caring ssh bruteforce attack since 09-Jan-2022  to 6-12-2022
![](https://i.ibb.co/DDsQ5VM8/image12.png)
![](https://i.ibb.co/RGCWqXcL/image13.png)

### 5. Initial Investigation and Traffic Analysis

- The traffic originated from an external public IP address and was not associated with internal systems.  
- No legitimate business activity or scheduled testing was identified at the time of the alert.  
- The User-Agent string is outdated and commonly used by automated attack tools.  
- The HTTP response status was 200 OK, and the response size was larger than usual, which may indicate successful command execution.

![](https://i.ibb.co/WTZssBw/image14.png)
![](https://i.ibb.co/6c5nxjSs/image15.png)
These indicators strongly reduce the likelihood of a false positive.

### 6. Email and User Activity Review

- No emails, maintenance tasks, or internal testing activities were recorded during the time of the alert.  
- No authorized user activity matched the request.

This confirms the traffic was not internally generated.

### 7. System Log Analysis

- System logs indicate evidence of unauthorized command execution.  
- The attack appears to have succeeded within a Docker container environment.  
- The attacker likely gained root privileges inside the container, but not on the host system.
![[Pasted image 20260113152047.png]]
![[Pasted image 20260113152120.png]]
This points to a container-level compromise rather than a full system breach.

### 8. Impact Assessment

- Scope of access: Limited to Docker container  
- Host system compromise: No  
- Potential data exposure: Limited to container  
- Persistence risk: Low after container reset  
Although contained, this is still considered a **successful exploitation attempt**.

### 9. Recommended Actions

1. Immediately isolate and reset the affected container  
2. Patch the vulnerable web application  
3. Improve input validation and sanitization  
4. Implement WAF rules to block command injection patterns  
5. Monitor for additional activity from the source IP  
6. Block the source IP if no legitimate business need exists  

### Final Verdict

True Positive – Confirmed Web Attack  

The alert represents a successful command injection attack that resulted in root-level access within a Docker container. Although the host system was not compromised, immediate remediation and hardening are required.



