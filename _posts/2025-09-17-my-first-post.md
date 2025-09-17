---
title: "Core Processes in Windows System: Understanding and Baselining"
date: 2025-09-17 14:00:00 +0800
categories: [windows, processes, security]
tags: [windows, system, kernel, security, baselining]
excerpt: "Learn about essential Windows processes, normal vs abnormal behavior, and how they can be used for baselining and monitoring."
author: Wrench L
image: /images/blog_images/win_proc.png    # optional featured image
---

# Core Processes in Windows System

**Date:** 9 September 2025  
**Read Time:** ~10 mins  
**Tags:** Windows System  

---

## Table of Contents

- [Introduction](#introduction)  
- [System (ntoskrnl.exe)](#system-ntoskrnlexe)  
- [smss.exe (Session Manager Subsystem)](#smssexe-session-manager-subsystem)  
- [csrss.exe (Client Server Runtime Process)](#csrssexe-client-server-runtime-process)  
- [wininit.exe (Windows Initialization Process)](#wininitexe-windows-initialization-process)  
- [services.exe (Service Control Manager)](#servicesexe-service-control-manager)  
- [svchost.exe (Service Host)](#svchostexe-service-host)  
- [lsass.exe (Local Security Authority Subsystem Service)](#lsassexe-local-security-authority-subsystem-service)  
- [winlogon.exe (Windows Logon)](#winlogonexe-windows-logon)  
- [explorer.exe (Windows Explorer)](#explorerexe-windows-explorer)  
- [Baselining and Security Monitoring](#baselining-and-security-monitoring)  
- [References](#references)

---

## Introduction

This article aims to help you understand **normal behavior within a Windows operating system** by detailing the core processes that run at boot and during normal operations. Knowledge of these processes helps with:  

- System baselining for security monitoring  
- Detecting anomalous or malicious activity  
- Understanding Windows internals for troubleshooting and auditing  

These core processes are also referenced in monitoring and intrusion detection tools like **Snort**, where baseline behavior is crucial for alerting on anomalies.

---

## System (ntoskrnl.exe)

The **System process** is the kernel of Windows and always has **PID 4**. It hosts **kernel-mode threads** with all attributes of user-mode threads but without a user-space memory context.  

**Responsibilities:**  

- CPU scheduling  
- Memory management (paged/non-paged pools)  
- Hardware abstraction via device drivers  
- Handling critical errors and Blue Screens  

**Normal vs Abnormal Behavior:**

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | N/A or C:\Windows\System32\ntoskrnl.exe | Other paths |
| Parent Process | None / System Idle Process | Any other parent |
| PID | 4 | Different PID |
| Instances | One | Multiple |
| User | Local System | Not Local System |
| Start Time | Boot time | Not at boot |
| Session | Session 0 | Other session |

---

## smss.exe (Session Manager Subsystem)

**smss.exe** creates **new sessions** and starts user-mode processes:

- Starts `csrss.exe` and `wininit.exe` for Session 0  
- Starts `csrss.exe` and `winlogon.exe` for user sessions  
- Manages environment variables and paging files  

**Normal vs Abnormal Behavior:**

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\smss.exe | Different path |
| Parent Process | System | Other than System |
| Instances | One master + child per session | More than one master; child does not exit |
| User | Local System | Not SYSTEM |
| Start Time | Within seconds of boot | Deviates |

---

## csrss.exe (Client Server Runtime Process)

Handles **Win32 console windows, thread creation, and shutdown**. Also maps drives and exposes Windows API to other processes.  

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\csrss.exe | Other path |
| Parent Process | smss.exe | Other |
| Instances | Typically two (Session 0 & 1) | Additional rogue instances |
| User | SYSTEM | Non-SYSTEM |
| Start Time | Seconds after boot | Deviates |

---

## wininit.exe (Windows Initialization Process)

Starts:

- `services.exe` (Service Control Manager)  
- `lsass.exe` (Security Authority)  
- `lsaiso.exe` (Credential Guard / KeyGuard, if enabled)  

**Normal vs Abnormal Behavior:**

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\wininit.exe | Other path |
| Parent | smss.exe | Other |
| Instances | One | Multiple |
| User | SYSTEM | Not SYSTEM |
| Start Time | Seconds after boot | Deviates |

---

## services.exe (Service Control Manager)

Manages **Windows services** like `svchost.exe`, `spoolsv.exe`, `msmpeng.exe`.  

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\services.exe | Other path |
| Parent | wininit.exe | Other |
| Instances | One | Multiple |
| User | SYSTEM | Not SYSTEM |
| Start Time | Seconds after boot | Deviates |

---

## svchost.exe (Service Host)

Hosts **Windows services implemented as DLLs**. Often multiple instances exist. Malware may impersonate svchost.exe.  

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\svchost.exe | Other path |
| Parent | services.exe | Other |
| Instances | Many | Rogue instances |
| User | SYSTEM / Network Service / Local Service / logged-in user | Other |
| Start Time | Seconds after boot | Deviates |
| Command Line | Must include `-k` parameter | Missing or altered |

---

## lsass.exe (Local Security Authority Subsystem Service)

Handles **authentication, tokens, and security policies**. Target for credential-dumping attacks.  

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\lsass.exe | Other path |
| Parent | wininit.exe | Other |
| Instances | One | Multiple |
| User | SYSTEM | Not SYSTEM |
| Start Time | Seconds after boot | Deviates |

---

## winlogon.exe (Windows Logon)

Manages **Secure Attention Sequence (Ctrl+Alt+Del)**, profile loading, userinit, screen locking, and screensaver execution.  

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\System32\winlogon.exe | Other path |
| Parent | smss.exe | Other |
| Instances | One or more | Deviates |
| User | SYSTEM | Not SYSTEM |
| Start Time | Seconds after boot | Deviates |
| Shell | explorer.exe | Other shell |

---

## explorer.exe (Windows Explorer)

Provides the **desktop environment, Start menu, Taskbar, and File Explorer**.  

| Property | Normal | Abnormal |
|---|---|---|
| Image Path | %SystemRoot%\explorer.exe | Other |
| Parent | userinit.exe | Other |
| Instances | One or more per user | Deviates |
| User | Logged-in users | Unknown user |
| Start Time | First interactive login | Deviates |
| Notes | Handles GUI, can be restarted if terminated | Outbound connections or anomalies |

---

## Baselining and Security Monitoring

Understanding these **core processes** allows security teams to **baseline a Windows system**:

- Establish what is normal (process path, PID, user, number of instances)  
- Detect deviations such as rogue processes, malware, or misconfigurations  
- Tools like **Snort, OSSEC, or Sysmon** can leverage this baseline for alerts  

**Example:**  
- Snort rules can monitor for unexpected paths, multiple instances, or processes running under wrong user accounts.  
- Endpoint detection systems can compare live process metadata with baselined information.

---

## References

- [Core Windows Processes](https://docs.microsoft.com/en-us/windows/win32/procthread/system-process)  
- [Hunt Evil](https://www.huntevil.com/)  
- Windows Internals, 7th Edition  

---

**Author:** wrench

**Note:** Understanding these processes helps not just for security monitoring, but also for troubleshooting, forensic analysis, and safe system configuration.
