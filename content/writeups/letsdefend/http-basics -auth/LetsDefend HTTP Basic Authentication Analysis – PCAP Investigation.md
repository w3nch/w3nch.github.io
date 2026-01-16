---
title: "LetsDefend HTTP Basic Authentication Analysis – PCAP Investigation"
date: 2026-01-14
tags: ["letsdefend", "soc", "http", "pcap", "wireshark", "web"]
categories: ["SOC Writeups", "Network Forensics"]
draft: false
---


## Description

In this challenge, we receive a log indicating a possible web-based attack.  
The objective is to analyze a provided PCAP file and extract meaningful information related to HTTP activity and authentication.


## Investigation Process

### Recovering the PCAP File

The PCAP was initially obtained in a Vm from there i obtained the files.  
The following commands were used to take the files out of the vm as here was not much network traffic so no large size of the file:

```bash
base64 cap.pcap > cap.b64  
base64 -d cap.b64 > recovered.pcap  
```
After decoding, the file size was verified to confirm successful recovery.

![](https://i.ibb.co/21c6YWz2/image1.png)
### Traffic Overview

Initial inspection in Wireshark showed:

- A very small number of packets
- Mostly ICMP and HTTP traffic
- Very few unique IP addresses

This suggests focused communication rather than automated scanning or exploitation.
![](https://i.ibb.co/1JpNVprD/image3.png)



### Network Observations

- The IP address 1.1.1.5 is mainly associated with ICMP traffic and may represent a DHCP or internal service.
- The most likely client (possible attacker) IP is 192.168.63.20.
- Since the traffic is from an internal network, this could also represent legitimate user activity.

![](https://i.ibb.co/vWdjRyk/image4.png)
![](https://i.ibb.co/FSZK9hH/image2.png)

### Filtering HTTP Requests

To identify HTTP GET requests, the following Wireshark filter was applied:
![](https://i.ibb.co/0RYp42jM/image5.png)

http.request.method == "GET"

This confirmed that there are exactly five HTTP GET requests in the capture.


![](https://i.ibb.co/s96h9Mn3/image6.png)

### Extracting Credentials from HTTP Basic Authentication

An Authorization header was discovered in one of the HTTP requests:

Authorization: Basic d2ViYWRtaW46VzNiNERtMW4=

HTTP Basic Authentication uses Base64 encoding.  
Decoding this value reveals the credentials:

webadmin:W3b4Dm1n




### Full HTTP Request and Response

GET / HTTP/1.0  
Host: 192.168.63.100  
Accept: text/html, text/plain, text/css, text/sgml, */*;q=0.01  
Accept-Encoding: gzip, compress, bzip2  
Accept-Language: en  
User-Agent: Lynx/2.8.7rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.8n  
Authorization: Basic d2ViYWRtaW46VzNiNERtMW4=  

HTTP/1.1 200 OK  
Date: Thu, 20 Jan 2011 07:39:08 GMT  
Server: Apache/2.2.15 (FreeBSD) DAV/2 mod_ssl/2.2.15 OpenSSL/0.9.8n  
Content-Type: text/html  
Content-Length: 44  

<html><body><h1>It works!</h1></body></html>



## Conclusion

This challenge demonstrates why HTTP Basic Authentication without TLS is insecure.  
Credentials can be trivially extracted from packet captures.

Key takeaways:

- Base64 is not encryption
- Credentials should never be transmitted without TLS
- Internal network traffic must still be monitored
- PCAP analysis is a critical SOC skill



## Challenge Questions & Answers

1. How many HTTP GET requests are in the PCAP?  
   Answer: 5

2. What is the server operating system?  
   Answer: FreeBSD

3. What is the name and version of the web server software?  
   Answer: Apache/2.2.15

4. What is the version of OpenSSL running on the server?  
   Answer: OpenSSL/0.9.8n

5. What is the client’s User-Agent?  
   Answer: Lynx/2.8.7rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.8n

6. What username was used for HTTP Basic Authentication?  
   Answer: webadmin

7. What password was used for HTTP Basic Authentication?  
   Answer: W3b4Dm1n


#letsdefend #soc #http #pcap #wireshark #networkforensics
