---
title: "SOC127 Case Study: Successful SQL Injection Attack via Automated Tooling"
date: 2026-01-29
tags: [letsdefend, soc, blue-team, sql-injection, web-security]
categories: [SOC Writeups, sqli & RCE]
draft: false
---

**Alert Name:** SOC127 – SQL Injection Detected  
**Severity:** High  
**Event ID:** 235  
**Event Time:** Mar 07, 2024 – 12:51 PM  
**Category:** Web Application Attack  
**Platform:** LetsDefend SOC

This incident shows how someone on the internet tried to trick a website into giving out information it wasn’t supposed to. Instead of breaking in directly, the attacker sent specially crafted messages to the website to see how it would respond.

Even though the website replied with “everything is OK,” it was actually doing things it shouldn’t have in the background. This shows that systems can look normal on the surface while still being misused.

It also shows that attackers often use automated tools to test many tricks very quickly. Once they find a weak spot, they can start pulling information from the system.

The big takeaway is that websites need to be built carefully and constantly monitored, because small weaknesses can allow outsiders to access sensitive information without anyone noticing right away.

---

## **Alert Overview**

A high-severity SQL injection alert was triggered after suspicious HTTP requests were detected originating from an external IP address targeting a web application.

SQL injection attacks allow attackers to manipulate backend database queries by injecting malicious SQL code through user-controllable input fields. In this case, multiple parameters were identified as vulnerable, allowing the attacker to interact with the database directly.

## **Key Event Details**
| Field                 | Value          |
| --------------------- | -------------- |
| Destination Hostname  | WebServer1000  |
| Destination IP        | 172.16.20.12   |
| Source IP             | 118.194.247.28 |
| HTTP Method           | GET            |
| Vulnerable Parameters | `id`, `douj`   |
| HTTP Status           | 200 (Success)  |
| Response Size         | 865 bytes      |
| Tool Identified       | sqlmap 1.7.2   |
| Device Action         | Allowed        |

## **Threat Indicators Identified**

- Automated SQL injection tool usage (sqlmap)
- Boolean-based SQL injection payloads
- UNION-based SQL injection
- Database enumeration attempts
- Obfuscated SQL payloads using XML and character encoding
- Dangerous function calls (`xp_cmdshell`)
- Consistent successful HTTP responses


### **Attack Flow & Timeline**

| Time (UTC) | Activity                                  |
| ---------- | ----------------------------------------- |
| 12:50 PM   | Port scanning activity detected           |
| 12:51 PM   | Initial SQL injection payload observed    |
| 12:51 PM   | UNION-based data extraction attempts      |
| 12:53 PM   | Boolean-based SQL injection confirmation  |
| 12:53 PM   | Continued automated exploitation attempts |

## **Payload Analysis (Examples)**


![](https://i.ibb.co/4wFV0RnQ/Pasted-image-20260129150705.png)

### **UNION-Based SQL Injection**

```
UNION ALL SELECT 1,NULL,'<script>alert("XSS")</script>',table_name FROM information_schema.tables
```
### **Boolean-Based SQL Injection**

```
id=1 AND 9816=9452--
```
### **Obfuscated SQL Injection**

```
CAST((CHR(113)||CHR(107)||CHR(107)||CHR(118)||CHR(113))||(SELECT (CASE WHEN (2574=2574) THEN 1 ELSE 0 END))::text AS NUMERIC)
```
### **Command Execution Attempt**

```
EXEC xp_cmdshell('cat ../../../etc/passwd')
```

These payloads confirm **active exploitation and post-exploitation testing**.

## **Reputation Check**

The source IP **118.194.247.28** was checked against multiple threat intelligence platforms:

- [VirusTotal](https://www.virustotal.com/gui/ip-address/118.194.247.28)
![](https://i.ibb.co/dwdsCg7B/Pasted-image-20260129150334.png)
- [AbuseIPDB](https://www.abuseipdb.com/check/118.194.247.28)
![](https://i.ibb.co/9kryZgMR/Pasted-image-20260129150343.png)
- [Cisco Talos](https://talosintelligence.com/reputation_center/lookup?search=118.194.247.28)
![](https://i.ibb.co/fdkLtwfQ/Pasted-image-20260129150416.png)
The IP address was reported for **web attacks, scanning activity, and malicious behavior**, further validating the malicious nature of the traffic.

## **Attack Assessment**

- **SQL Injection Successful:** Yes
- **Database Interaction:** Confirmed
- **Database Enumeration:** Observed
- **Command Execution:** Attempted (not confirmed)
- **Planned Test:** No
- **Traffic Direction:** Internet → Company Network

This incident represents a **successful compromise of the web application’s database layer**.

## **Impact Assessment**

- Unauthorized database access: **Yes**
- Data exposure: **Possible**
- Web application integrity: **Compromised**
- Risk of escalation: **High**
- Business impact: **High**

## **Lessons Learned**

- Public-facing applications must be protected against SQL injection.
- Input validation and prepared statements should be enforced.
- Web Application Firewalls (WAF) must be enabled and tuned.
- Dangerous database functions should be disabled.
- Continuous monitoring of HTTP traffic is essential.
- Regular security testing and code reviews are critical.

## MITRE ATT&CK Mapping
|Tactic|Technique|ID|
|---|---|---|
|Reconnaissance|Active Scanning|T1595|
|Initial Access|Exploit Public-Facing Application|T1190|
|Discovery|Database Enumeration|T1083|
|Execution|Command Injection|T1059|
## **Artifacts Collected**

|Artifact|Value|
|---|---|
|Attacker IP|118.194.247.28|
|Target Host|WebServer1000|
|Tool|sqlmap 1.7.2|
|HTTP Endpoints|`/`, `/index.php`|
|Vulnerable Parameters|`id`, `douj`|


## Sigma Rules
- [Dangerous Database Function Abuse (xp_cmdshell)](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC127%20-%20SQL%20Injection%20Detected/web_sql_cmd_execution_attempt.yml)
- [SQL Injection Payload Keywords (UNION / Boolean)](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC127%20-%20SQL%20Injection%20Detected/web_sql_injection_obfuscated.yml)
- [Obfuscated SQL Injection (CHR / CAST)](https://github.com/w3nch/Sigma-rules/blob/main/LetsDefend/SOC127%20-%20SQL%20Injection%20Detected/web_sql_injection_payloads.yml)


## **Final Verdict**

**True Positive – Successful SQL Injection Attack**

The attacker successfully exploited a SQL injection vulnerability using automated tooling, gaining unauthorized interaction with the backend database. Although full system compromise was not confirmed, this incident represents a **critical application security failure** requiring immediate remediation.

## **Analyst Note**

This case highlights how automated tools such as sqlmap can rapidly exploit poorly protected web applications. Even without confirmed operating system compromise, database-level access poses significant risk. Strong input validation, secure coding practices, and proactive web security monitoring are essential to prevent similar incidents.


