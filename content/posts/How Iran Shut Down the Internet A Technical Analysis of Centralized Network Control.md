---
title: "How Iran Shut Down the Internet: A Technical Analysis of Centralized Network Control"
date: 2026-02-11
tags: [network, security, analysis, BGP]
categories: [Networking, BGP, Meet-me room]
draft: false
---




**Disclaimer:** This article is written from a purely technical perspective to educate readers about internet infrastructure and network architecture. I have no political affiliation and seeks only to examine the technical mechanisms that enabled Iran's 2026 internet shutdown.

## Introduction

On January 8, 2026, at 8:00 PM Iran Standard Time, approximately 92 million Iranian citizens were suddenly disconnected from the global internet. This shutdown, which began during the twelfth day of nationwide protests, represented one of the most extensive and sophisticated internet blackouts ever recorded [Wikipedia](https://en.wikipedia.org/wiki/2026_Internet_blackout_in_Iran)  [Georgia Tech News](https://news.gatech.edu/news/2026/01/16/irans-latest-internet-blackout-extends-phones-and-starlink). Unlike temporary disruptions or partial outages, this was a coordinated, nationwide termination of internet connectivity that persisted for weeks.

To understand how an entire nation's internet access can be switched off like a light, we need to examine the fundamental architecture of how the internet works, the critical infrastructure that connects countries to the global network, and how Iran's unique centralized telecommunications structure created a single point of failure that the government could exploit.

## Prerequisites: Understanding BGP

Before going into Iran's specific case, it's essential to understand the Border Gateway Protocol (BGP) the routing protocol that makes the global internet possible.

![](https://duckduckgo.com/i/9a54055f034717d2.png)

### What is BGP?

BGP is the postal service of the internet. When you send a letter, you don't need to know every road between you and the recipient and you simply trust the postal service to figure out the best route. Similarly, when data travels across the internet, BGP determines the path that information takes between different networks.

The internet isn't a single unified network. Instead, it's a collection of tens of thousands of independent networks called Autonomous Systems (AS). Each AS has a unique identifier (ASN) and can be an internet service provider, a large corporation, a university, or even a country's national network. BGP is the protocol these autonomous systems use to communicate with each other and exchange routing information.

### How BGP Works

When an AS wants to announce its presence to the internet, it broadcasts BGP announcements that essentially say, "I have these IP addresses, and here's how to reach them." Other networks receive these announcements and update their routing tables accordingly. This process happens continuously across the entire internet, creating a constantly updating map of how to reach every network.

### The Risk

Here's the critical point: BGP operates on trust. When a network makes an announcement, other networks generally accept it without verification. This design dates back to the internet's early days when it connected a small number of research institutions that trusted each other implicitly.

This trust-based system creates significant vulnerabilities:
1. **Route hijacking**: A malicious actor can announce they have the best route to certain IP addresses, redirecting traffic through their network
2. **Centralization risks**: If all internet traffic for a country must flow through a small number of connection points, controlling those points gives complete control over internet access
3. **Single point of failure**: When BGP announcements are withdrawn, networks become unreachable

## Iran's Internet Architecture: A Study in Centralization


### The Telecommunication Infrastructure Company (TIC)

The Telecommunication Infrastructure Company [(TIC)](https://bgp.he.net/AS197207#_asinfo) is the governmental body responsible for telecommunication network infrastructure in Iran, operating under the Ministry of Information and Communications Technology [Wikipedia](https://en.wikipedia.org/wiki/Telecommunication_Infrastructure_Company). 

![](https://i.ibb.co/bM4gk5Jg/Pasted-image-20260211165446.png)

TIC serves as the main governmental body with nearly complete control over the country's internet infrastructure [FilterWatch](https://filter.watch/english/2024/10/10/https-filteinvestigative-report-september-2024-internet-infrastructure-monopoly/).

What makes Iran's setup unique is the extreme centralization of this control. TIC manages:

![](https://i.ibb.co/BKZFX3hL/Pasted-image-20260211165021.png)

- International internet gateways (all entry/exit points for internet traffic)
- The national fiber optic backbone (71,500 km as of 2024)
- Bandwidth allocation to all ISPs
- Domestic bandwidth capacity (76,000 Gbps)
- International bandwidth connections (62,000 Gbps)

### Comparing Network Topology
To understand the significance of Iran's architecture, let's compare BGP peer relationships for Iranian networks versus those in countries with competitive telecommunications markets.

Country like india,canada and many other have network topology like shown below having private internet providers:

![](https://i.ibb.co/5hXfNjB5/Pasted-image-20260211173340.png)

- Multiple independent international connections
- Diverse peering relationships with neighboring countries
- Multiple autonomous paths to reach the global internet
- Distributed architecture without single points of control

This architectural difference is crucial. In most countries, shutting down the internet would require coordinating with dozens or hundreds of independent ISPs and international carriers. In Iran, the government only needs to control TIC.

### The Role of Meet-Me Rooms

A meet-me room (MMR) is a physical location where different telecommunications networks interconnect. In most countries, multiple competing carriers meet in these rooms to exchange traffic through neutral exchange points. This creates a distributed, resilient network architecture.

In Iran, the government controls the primary meet-me rooms and international exchange points through TIC. All internet traffic flowing in and out of the country must pass through these government-controlled facilities, creating the perfect chokepoint for implementing a shutdown.

## Technical Implementation of the January 2026 Shutdown

On January 8, 2026, at 8 p.m. Iran Standard Time, the Iranian regime shut down the internet, with measurements showing only about 3% responsiveness to active network probing [Georgia Tech News](https://news.gatech.edu/news/2026/01/16/irans-latest-internet-blackout-extends-phones-and-starlink). The shutdown targeted even the domestic Iranian intranet, while allowing government leaders to continue using social media such as X and Telegram [Chatham House](https://www.chathamhouse.org/2026/01/irans-internet-shutdown-signals-new-stage-digital-isolation).

### Evolution of Shutdown Techniques

The Internet Outage Detection and Analysis project has been measuring internet connectivity globally since 2011, and its long view of global internet connectivity offers insight into the Iranian regime's developing sophistication in controlling information and shutting down the internet [Georgia Tech News](https://news.gatech.edu/news/2026/01/16/irans-latest-internet-blackout-extends-phones-and-starlink).

**2019 Shutdown ("Bloody November"):**

- Primary method: Turning off BGP routing announcements
- Duration: Almost seven days
- Characteristics: Blunt force approach, partial circumvention possible
- Evidence of varied disconnection timing by different ISPs

**2022 Shutdown (Women, Life, Freedom protests):**

- Two weeks of nightly mobile phone network shutdowns
- More targeted but still incomplete

**2026 Shutdown (Current):** The regime did not sever access but instead degraded function by sabotaging the protocols that make the internet usable, rather than disconnecting gateways [Middle East Forum](https://www.meforum.org/mef-observer/how-iran-augmented-its-internet-shutdown-strategy-in-2026). According to digital rights groups, the Iranian regime implemented the shutdown by interfering with transport layer security and the domain name system [Chatham House](https://www.chathamhouse.org/2026/01/irans-internet-shutdown-signals-new-stage-digital-isolation)[Georgia Tech News](https://news.gatech.edu/news/2026/01/16/irans-latest-internet-blackout-extends-phones-and-starlink).

### Multi Layered Shutdown Approach

The 2026 shutdown employed multiple simultaneous techniques:

1. **BGP Route Withdrawal**: Ceasing to announce Iranian IP address blocks to the global internet
2. **DNS Interference**: Disrupting domain name resolution
3. **TLS Disruption**: Interfering with encrypted connections
4. **Physical Infrastructure**: Disabling mobile network antennas, cutting phone lines
5. **Deep Packet Inspection**: Selective blocking of high-volume data transfers
6. **SIM Card Deactivation**: Targeting dissident citizens and activists

### Starlink Jamming

In an unprecedented move, the government is reportedly jamming satellite signals using military-grade mobile jammers, which slow or block connectivity [Chatham House](https://www.chathamhouse.org/2026/01/irans-internet-shutdown-signals-new-stage-digital-isolation). This represents a significant escalation, as Starlink had previously provided a circumvention method during earlier shutdowns.

## Monitoring the Shutdown: Cloudflare Radar Data

Cloudflare Radar provides real-time visibility into internet traffic patterns globally. The data for Iran during January 2026 shows:

![](https://i.ibb.co/NgsX7J4x/Pasted-image-20260211164724.png)

- Dramatic drop in HTTP/HTTPS requests
- Near-complete elimination of DNS queries
- Cessation of BGP route announcements
- Traffic volumes dropping to near-zero

This data correlates with measurements from other monitoring platforms like NetBlocks and the Georgia Tech Internet Intelligence Lab, all confirming a comprehensive, coordinated shutdown.

## The Architecture of Control: Why This Was Possible

The technical implementation of Iran's shutdown was possible because of several architectural decisions made over decades:

### 1. Government-Owned Infrastructure Backbone

Unlike countries where private companies own the fiber optic cables and international links, Iran's backbone is government-owned through TIC. This means:

- No need to negotiate with private companies
- Direct control over physical infrastructure
- Ability to modify routing policies unilaterally

### 2. Centralized International Gateways

All international internet traffic flows through a limited number of government-controlled points. When these gateways stop announcing routes via BGP or simply shut down, the entire country goes dark.

### 3. Hierarchical ISP Structure

Even the domestic Iranian intranet operates under TIC supervision, with internet service providers forced to route traffic through TCI-controlled chokepoints for real-time inspection [FilterWatch](https://filter.watch/english/2024/10/10/https-filteinvestigative-report-september-2024-internet-infrastructure-monopoly/).

### 4. National Information Network (NIN)

Iran has developed a domestic intranet separate from the global internet. Cybersecurity experts reported that Iran's National Information Network was also fully disconnected, even internally within Iran [Wikipedia](https://en.wikipedia.org/wiki/2026_Internet_blackout_in_Iran). This dual structure allows selective connectivity for government services while blocking citizen access.

## The Future: "Barracks Internet"

Following the repressive crackdown on protests, the government is now building a system that grants web access only to security-vetted elites, while locking 90 million citizens inside an intranet, called Barracks Internet according to confidential planning documents [Rest of World](https://restofworld.org/2026/iran-blackout-tiered-internet/).

Government spokesperson Fatemeh Mohajerani confirmed international access will not be restored until at least late March, with sources saying access will never return to its previous form [Rest of World](https://restofworld.org/2026/iran-blackout-tiered-internet/).

## Technical Lessons and Implications

### The Fragility of Centralized Networks

Iran's case demonstrates how centralized network architecture creates systematic risk. When a single entity controls:

- International gateways
- BGP route announcements
- Physical infrastructure
- Backbone connectivity
### BGP as a Tool of Control

While BGP's trust-based model enables the global internet to function, it also enables authoritarian control when combined with centralized infrastructure. Simply withdrawing BGP announcements makes a country's networks unreachable globally.

### The Limitations of Circumvention Tools

Previous internet blackouts in Iran were less sophisticated in scope, allowing some people to circumvent them via VPNs and censorship-resistant technologies such as peer-to-peer networks [Chatham House](https://www.chathamhouse.org/2026/01/irans-internet-shutdown-signals-new-stage-digital-isolation). However, the 2026 shutdown demonstrated that when a government controls the physical infrastructure and can implement military-grade jamming, even satellite internet becomes ineffective.

## Conclusion

The Iranian internet shutdown of January 2026 represents the culmination of decades of centralized infrastructure development that created a network architecture with a single point of failure intentional and by design.

The global internet was designed to route around damage and censorship. Iran's case shows that when a government controls the physical infrastructure, the routing protocols, and the international gateways, even the most resilient global network can be severed at the national border.

This technical analysis serves as a reminder that internet freedom depends not just on protocols and software, but on the fundamental architecture of who controls the physical infrastructure that makes connectivity possible.
