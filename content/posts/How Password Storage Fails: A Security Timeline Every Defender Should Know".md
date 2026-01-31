---
title: "How Password Storage Fails: A Security Timeline Every Defender Should Know"
date: 2026-01-31
tags: [passwords, infosec, blue-team, hashing, breaches, soc]
categories: [Defensive Security, Identity Security]
draft: false
---

Storing passwords safely is a really important part of running any website or app where people create accounts. When this is done badly, it has led to some of the biggest data leaks ever. Even years later, stolen passwords are still being reused by attackers to break into other accounts.

Below are six common ways passwords have been handled over time, starting with the worst ideas and moving toward safer ones, explained in a simple way.

---


## 1. Plain Text

Plain text storage means a password is saved exactly as a person types it. If someone creates an account with a password like `hello123`, that exact text is stored in the database.

![](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.next7it.com%2Fwp-content%2Fuploads%2F2019%2F05%2FPlain-Text-Password.jpg&f=1&nofb=1&ipt=657fa3be1078e3781ca9daf34f8248fb36cfae57c4fe1ad1e3afd7c89c981330)

This approach was common in the early internet era around `1990-2000`, when security was not treated as a serious concern. At that time, strong cryptography was either difficult to use or legally restricted. In the United States during the 1990s, encryption was classified as a munition. Exporting strong cryptographic software outside the country could be illegal. This period is often referred to as the [crypto wars](https://darknetdiaries.com/transcript/12/) and is discussed in depth in podcasts like [Darknet Diaries](https://darknetdiaries.com/), which explain how many early security disasters happened simply because the internet was not built with attackers in mind.

When passwords are stored in plain text, there is no protection at all. If someone gains access to the database, every password is immediately readable. Nothing needs to be cracked or guessed. Since people commonly reuse passwords across email, social media, and shopping sites, a single breach can spread far beyond the original service.

The [RockYou breach in 2009](https://techcrunch.com/2009/12/14/rockyou-hack-security-myspace-facebook-passwords/) is one of the most well known examples. Millions of passwords were leaked because they were stored in plain text. Those passwords later became part of [wordlists](https://github.com/danielmiessler/SecLists/blob/master/Passwords/Leaked-Databases/rockyou-75.txt) that attackers still use today in credential stuffing attacks. A mistake made more than a decade ago continues to harm users today.


## 2.  Encryption

To improve on plain text, some systems began encrypting passwords before storing them. Instead of saving the password directly, the system encrypts it using algorithms such as AES-256 or RSA and stores the encrypted output.

![](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fasecuritysite.com%2Fpublic%2Frsa_0002.png&f=1&nofb=1&ipt=bd8075c2a4c192392b4ebc86651dadfa5e5499bfb5e55a570fe2b80963c3109e)

At first glance, this looks secure. The password is no longer readable. However, encryption has one unavoidable requirement. It needs a key.

That key must be stored somewhere so the application can decrypt the password when needed. If an attacker ever gains access to both the database and the encryption key, every password can be decrypted instantly.

If you want to try it for your self visit [encrypt-online](https://encrypt-online.com/tools/rsa-encryption).

Encrypted output (base64)
```rsa
PyzxyJUXcR+k9MPv0JRBCywR9ygV+oBk5SiD0pYT70j8kLAMzb88DzzplBUFjCJk7FS+YYQn9DDZakfBD57nxvIyN+FzGARL48dGjv3ougzpDG0wxg8cXRswLHBa0JAM3+Ch8g1Otl1Cn3k7WDpg7OD3Ip2+7pBq4ZH/InI7TvddsWo/bQEMvy7C4I8tfvZ2Id0xZDGApDsuPfPCabsOz99Ilz3XlrRJKRd0KSkPXWV/61u1bhBlJ45wOqhn2nDnS3L19SOKx9rm4FPe4uipxGR21N4lKevAOaf6ChRnpFcpBA14sF4yMRggIMljoaXAfQpalbL5F/DDAOgc3LZn5A==
```
Private key: Private key (PEM)
```rsa
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDZ66sGOk3vyBqP
7jyjWqXacjBAL1grS9g99edc8jlwc9Xjri7MCx+hMGpf6VP8AC4Ej6I456fxbOEI
+9mtXoj70QTmx4CywRrf0sgVrdGPxoieoloq70eYbHboNT+8HQLFiRs0sFiB+U68
TQ/a4TXID5eI9EapJvY/eePuxBSq/nRuCUij4hUVDYb2a/LKLN/QMGWHTM+GlA/D
J7PcAcV7SrtiN1G0BYw9CeUsrCNRf+NWFkUbXT3kd0Q8PJWw1+o3Jhud7JIAWrq1
EsxLx5yeBxzJqjyNHn9qNkpxWOrb25j0Ulb7qk9FS/H5jHDqvzPd3HVVG6Dab9H4
QV5jKr59AgMBAAECggEABGHu8JMfmiDmF9rssURTbY86VTAej9BYqvZVDtN4QEC0
Hn4URto6ap10pjUlET5XrpPM6WQPRpWv+ORHvmrWSmortRByECY+Ch5NE9KJEmEl
wjr1oUNqpzAXPBhGDdxvf9WADJE3VnXTFYpfNUGuOTXHEGQJP8Ge1iv3X4fl+oJW
Ap6/ZJ2MQlSOgXg10bkFPuKThBnrv90nJMS0Siy+xJbHFOdD//idV73Jb3JahSJT
41f47wvS0qXlUCLT8taoYm1kzWXHiKISeYqL6qsYZXmCqdqI/dxYaFJzA5kN/e3J
XLM9wrGsnd/VaVVFveYMyyOI2E0HiCsPeN0thUO0QQKBgQD9+39WSkhN8MntVrxK
ZZ1Cmv3hp90BNXmlalaCn+XtNJtLsHhWGmAclrLH7/4Dc1H48Y5xa7BN5b++uQyY
d92n0LD385sDxE19PBJUTzcwz5Q1UPgZEPAUqA/R1KHYNp0kJ0qwDWi3rPXldieQ
Y61+6J4jpujSg7kPE0iqwNWS2QKBgQDbptWx/PZzpROn/fHV20TXG5fTw/cFhV76
e88LYfpA5zXo9UWbBSHhA1phwZO3FMnhhZPQxOTm9/kuGeKq7qmb7OkNXnRWNxQE
cWwt8Roex3l7NmxwUyHvGJyxtSzbrjjEV5h1/xHxzqJTw78uYdEWO34H51Pbs9S+
P1uvqd06RQKBgQCP5M8OCmPQlJ0ytDNVSyC/vaQdFselibBzwT1mIEVaELXzOfXT
gnn1eIOttxCIz+sfSWvUYpiuaX4rBhhWwYJ5M0kwEXo/thXY4BHaZk70foaPdmI5
gVkjutvLm9Zd8wMwmno8KDyt43YlHL3pli+TeSMvO78olaxhGCHRbBMUcQKBgFQG
87L+UY2V9foLFKu6ERC1NpTFX8dV6SqrmF4DYkfX63Ct+628/ePlc3r4IbklE8HZ
Zt2zpNmSvVlcf7DiUjIbJGB/5MNimJ7GgRrmJBboOlnfTQZ/VvjvkmoNJBb6BC9g
Tyu8ozG82a5vsMBenS0DH0iIvzTKC7Wn6Tw/ICl9AoGAIyg7yq5AprV84TX0nYfO
vKSMf7dsVDzxa1Tmc4LRXT7OJ+lj/gc2IYtN1dj/LESjuC1P8hyeHLI+FO64kJ1w
LJ6qHjV42Zr/ccB/2vbovk5iQie1G1HjXc6TUzcmnkykklwsc+cSHij9eOXozhV3
vkYsm25gHOZBU5pVKwDlqcM=
-----END PRIVATE KEY-----
```

This has happened in real breaches. Encryption keys have been discovered hard coded in application source code, stored alongside databases, or exposed through backups and cloud misconfigurations. Once the key is compromised, encryption provides little protection.

![](https://i.ibb.co/vx0gr1Xp/Pasted-image-20260131141814.png)

The [Adobe breach in 2013](https://dehashed.com/insights/adobe-data-breach-2013-october) is a well known example. Adobe used reversible encryption instead of proper password hashing. Once attackers understood how the encryption worked, millions of passwords were exposed. That incident became a major lesson for the industry.

Encryption is designed for data that must be recovered later, such as files or messages. Passwords should never need to be recovered. They only need to be verified.

## 3. Hashing 

Hashing marked a major improvement. Instead of encrypting passwords, systems began converting them into fixed length values using hash functions. A password hashed with MD5 or SHA-1 cannot be reversed back into the original text.

Early hashing algorithms like MD5, SHA-1, and later SHA-256 were designed to be fast. Their original purpose was file integrity checking, not password protection.

That speed became the weakness. Modern CPUs and GPUs can compute millions or even billions of hashes per second. Attackers simply try large lists of common passwords until they find matches.

Huge databases of precomputed hashes already exit  online like [CrackStation](https://crackstation.net/). If a password appears in one of those lists, it can often be identified almost instantly. This is why many older breaches were devastating even though passwords were technically hashed.

```md5
5f4dcc3b5aa765d61d8327deb882cf99
```
Try to find the original text from this.

## 4. Hashing with Salt

Salting was introduced to fix a major flaw in basic hashing. A salt is a random value added to a password before hashing it. Even if two people use the same password, their stored hashes will be different.

![](https://i.ibb.co/XfxQq3mx/hahahah.png)
For example, the password  hashed with SHA-256 will always produce the same result. When a unique salt is added, the output becomes completely different for every user.

```sha-256
Salt + word + hashing = unique value
```

This change made precomputed hash tables useless and forced attackers to crack each password individually. It significantly raised the cost of attacks and stopped many large scale compromises.

Salting became common after repeated breaches showed that unsalted hashes were too easy to crack. However, if the hashing algorithm is still fast, attackers can continue guessing passwords quickly using modern hardware.

## 5. Slow Hashing 

To address the speed problem, password specific hashing algorithms were created. These include bcrypt, scrypt, PBKDF2, and Argon2.

![](https://i.ibb.co/W9q06vZ/Pasted-image-20260130185458.png)

These algorithms are intentionally slow. Each password guess takes noticeable time and often uses large amounts of memory. This makes brute force attacks expensive and slow, even when attackers use GPUs or specialized hardware.

They also include salting by default and allow systems to adjust the cost factor over time. As computers get faster, systems can increase the difficulty without forcing users to change their passwords.

Most modern applications that take security seriously use one of these methods today. Even if a database is stolen, cracking passwords becomes difficult and sometimes impractical.


## 6. Not Storing Passwords at All

The safest password is the one that does not exist.

![](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmattermost.com%2Fwp-content%2Fuploads%2F2022%2F12%2F03_Google_GitHub_Login%402x.png&f=1&nofb=1&ipt=4f5724fa954b529c6cead77d873389c9e7ef808d57996a42aaedef352e9a2699)

Many modern systems avoid traditional passwords entirely. They use technologies like time based one time passwords, hardware security keys, passkeys built into browsers and phones, or third party authentication providers such as Google or GitHub.

Because there is no password database, there is nothing useful to steal. Old leaked passwords cannot be reused, and phishing attacks become much harder.

This approach does introduce challenges like device loss and account recovery, but when designed properly it removes one of the most common causes of real world breaches.

---

Passwords should never be readable, never reversible, and never easy to guess. Most real breaches are not caused by advanced hacking techniques. They happen because basic design decisions were made years earlier and never corrected. Understanding how password storage evolved explains why modern systems work the way they do today.If you like to read more on this there is a amazin article on [medium by Renan Dias](https://dojowithrenan.medium.com/the-5-factors-of-authentication-bcb79d354c13)

