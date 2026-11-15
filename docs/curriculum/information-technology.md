# Information Technology curriculum

**Goal:** take a learner who has never looked inside a computer to the level of a working IT professional who can support users, run networks and Linux servers, secure systems and operate cloud infrastructure.

**Track overview**

```text
Zero          Computer Fundamentals from Zero  (exists, expand)
Beginner      Operating Systems in Practice → Computer Networking Fundamentals
Intermediate  Linux Essentials → Databases & SQL → IT Support Professional
Advanced      System Administration → Cybersecurity Fundamentals → Cloud Computing Fundamentals
Professional  DevOps & Cloud Engineering (capstone)
Expert        Specialisations: network engineering · security engineering · cloud architecture
```

Total guided learning is about 320–380 hours, plus projects.

---

## IT-0 · Computer Fundamentals from Zero

**Level:** Zero · **Access:** free · **Status:** published, 5 of 14 lessons · **About 14 h**

**Outcomes:** learners will be able to explain the input–process–store–output model, choose hardware for a use case, manage files and backups, install software safely, and protect their accounts.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. What a computer really is *(exists)* | What is a computer? ✓ · Hardware and software ✓ · Bits, bytes and number systems (binary, why 1 KB ≈ 1 000 B vs 1 024) | Label the four jobs in five everyday devices |
| 2. Inside the machine *(new)* | CPU: cores, clock speed and why more cores do not always help · Memory and storage: RAM, SSD, NVMe, HDD · Ports and peripherals (USB-C, HDMI, Wi-Fi, Bluetooth) · Reading a specification sheet | Compare three real laptops and pick one for a student, a video editor and an office |
| 3. Working with files *(exists, expand)* | Files, folders and paths ✓ · Installing and removing software safely · Backups and the cloud: the 3-2-1 rule | Build a folder structure and a backup plan for a small business |
| 4. Operating system basics *(new)* | What an operating system does · Users, accounts and permissions · Updates and why they matter | Find the OS version, storage use and running programs on your computer |
| 5. Safe on the internet *(new)* | Passwords, password managers and two-factor authentication · Phishing and scams (with local examples) | Spot-the-phish exercise using 10 realistic messages |
| Final | Project: *Spec, set up and secure a computer for a client brief* · Final assessment (exists, extend to 15 questions) | Rubric: spec justification, backup plan, security checklist |

---

## IT-1 · Operating Systems in Practice

**Level:** Beginner · **Access:** free · **About 20 h** · **Prerequisite:** IT-0

**Outcomes:** learners will be able to configure Windows and macOS confidently, use the command line for everyday tasks, manage software with package managers, and troubleshoot common problems.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. How operating systems work | Kernel, drivers and processes · File systems (NTFS, APFS, ext4) · Boot process | Draw what happens from power button to desktop |
| 2. Windows in depth | Settings vs Control Panel · Task Manager and resource monitoring · Users, UAC and permissions · Windows Update and recovery options | Create a standard user and test what it cannot do |
| 3. macOS in depth | System Settings · Activity Monitor · Gatekeeper and permissions · Time Machine | Restore a deleted file from a backup |
| 4. The command line | Why terminals exist · Navigating (`cd`, `ls`/`dir`, `pwd`) · Files (`cp`, `mv`, `rm`, `mkdir`) · PowerShell vs zsh/bash | Organise 50 files using only commands |
| 5. Software management | winget and Homebrew · Drivers · Uninstalling cleanly | Install a toolset with one script |
| 6. Troubleshooting | A step-by-step method · Slow computer · Won't boot · Disk full | Diagnose three scripted scenarios |
| Final | Project: *Prepare a new computer for a colleague* (accounts, updates, software, backups) with a written handover · Final assessment | |

---

## IT-2 · Computer Networking Fundamentals

**Level:** Beginner → Intermediate · **Access:** premium (first module free) · **About 30 h** · **Prerequisite:** IT-1

**Outcomes:** learners will be able to explain how data moves across networks, plan IPv4 addressing and subnets, configure a small office network, and troubleshoot connectivity with standard tools.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. What a network is | LAN, WAN and the internet · Packets · Network devices: switch, router, access point | Map your home network |
| 2. Models and protocols | OSI and TCP/IP models (what each layer is for) · TCP vs UDP · Ports | Match 15 protocols to layers and ports |
| 3. IP addressing | IPv4 structure · Private ranges and NAT · Subnet masks and CIDR · Subnetting step by step · IPv6 basics | 20 subnetting drills with instant feedback |
| 4. Core services | DHCP · DNS records (A, AAAA, CNAME, MX, TXT) · HTTP/HTTPS and TLS at a high level | Trace a DNS lookup with `nslookup`/`dig` |
| 5. Wireless | Wi-Fi standards and bands · Security (WPA3) · Placement and interference | Wi-Fi survey of a room with a phone app |
| 6. Troubleshooting | `ping`, `traceroute`/`tracert`, `ipconfig`/`ip`, `netstat`/`ss` · Layered troubleshooting method | Find faults in five lab scenarios |
| Lab environment | Cisco Packet Tracer (free with a Cisco NetAcad account) for routers and switches; VLANs at an introductory level | |
| Final | Project: *Network design for a 20-person office* — addressing plan, diagram, device list, Wi-Fi plan, security choices · Final assessment | Rubric published |

Aligned with the fundamentals in CompTIA Network+ and Cisco CCNA (introductory parts).

---

## IT-3 · Linux Essentials

**Level:** Intermediate · **Access:** premium · **About 30 h** · **Prerequisite:** IT-1

**Outcomes:** learners will be able to work comfortably in a Linux shell, manage users, permissions, packages and services, read logs, connect over SSH and automate tasks with Bash.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Getting Linux | Distributions · Installing in a virtual machine (VirtualBox, UTM on Apple Silicon) · WSL on Windows | Working Ubuntu VM |
| 2. The shell | Filesystem hierarchy · Navigation, globbing, pipes and redirection · `grep`, `find`, `less` · Text editors (nano, basic vim) | Command-line scavenger hunt |
| 3. Users and permissions | Users, groups and `sudo` · `chmod`/`chown` and octal permissions | Fix a broken permissions scenario |
| 4. Software and services | `apt`/`dnf` · `systemd` and `systemctl` · Logs with `journalctl` | Install and run nginx as a service |
| 5. Processes and resources | `ps`, `top`/`htop`, signals · Disk usage · Scheduling with cron and systemd timers | Find and stop a runaway process |
| 6. Networking and SSH | `ip`, `ss`, firewalls (ufw) · SSH keys and hardening | Key-only SSH login to a second VM |
| 7. Bash scripting | Variables, conditions, loops · Arguments and exit codes · Safe scripting habits | Backup script with rotation |
| Final | Project: *Set up and document a small Linux web server* · Final assessment | |

Aligned with the Linux Professional Institute Linux Essentials topics.

---

## IT-4 · Databases & SQL

**Level:** Intermediate · **Access:** premium · **About 24 h** · **Prerequisite:** IT-0 (cross-listed in Programming)

**Outcomes:** learners will be able to design a relational schema, write correct SQL (including joins and aggregates), use indexes and transactions, and back up and restore a database.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Why databases | Tables, rows and keys · Relational vs document stores | Model a library on paper |
| 2. Querying | `SELECT`, `WHERE`, `ORDER BY` · Aggregates and `GROUP BY` · `JOIN`s explained with diagrams | 40 graded queries on a sample dataset |
| 3. Changing data | `INSERT`/`UPDATE`/`DELETE` · Constraints · Transactions | Fix data with a safe transaction |
| 4. Design | Normalisation (1NF–3NF) in practice · Relationships · Naming | Design the schema for an online shop |
| 5. Performance and operations | Indexes and `EXPLAIN` · Backups and restore · Access control | Speed up a slow query |
| Final | Project: *Database for a local business* with 20 documented queries · Final assessment | |

PostgreSQL is used throughout; it is free and widely used.

---

## IT-5 · IT Support Professional

**Level:** Intermediate → Advanced · **Access:** premium · **About 30 h** · **Prerequisites:** IT-1, IT-2 (module 1–4)

**Outcomes:** learners will be able to resolve user problems methodically, maintain hardware, deploy operating systems, manage accounts and devices, and communicate and document like a support professional.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. The support role | Ticketing, priorities and SLAs · Communicating with non-technical users | Rewrite five poor ticket replies |
| 2. Troubleshooting method | Identify → theorise → test → plan → fix → verify → document | Ten simulated tickets |
| 3. Hardware | Safe handling and ESD · Replacing RAM and SSDs · Printers and peripherals | Hardware diagnosis flowcharts |
| 4. Deploying systems | Clean installs and imaging · Drivers and updates at scale · Mobile devices | Deploy a VM from an image |
| 5. Accounts and access | Local vs domain accounts · Password resets securely · Basic Microsoft 365 / Google Workspace administration concepts | Access request workflow |
| 6. Security in support | Malware removal · Phishing response · Data protection when handling user devices | Incident write-up |
| Final | Project: *Run a support desk for a week* (scenario-based, 25 tickets) · Final assessment | |

Aligned with the CompTIA A+ objectives.

---

## IT-6 · System Administration

**Level:** Advanced · **Access:** premium · **About 30 h** · **Prerequisites:** IT-3, IT-2

**Outcomes:** learners will be able to run Linux servers in production, serve web applications, automate configuration, monitor health and recover from failure.

| Module | Lessons |
| --- | --- |
| 1. Servers in production | Sizing, environments, change management |
| 2. Web serving | nginx as web server and reverse proxy · TLS certificates with Let's Encrypt |
| 3. Storage and backups | Disks, LVM and filesystems · Backup strategy and restore testing |
| 4. Monitoring and logs | Metrics vs logs · Alerting that people trust |
| 5. Automation | Configuration as code with Ansible · Idempotence |
| 6. Directory services | Active Directory and LDAP concepts · Group policy overview |
| Final | Project: *Automated, monitored web server with tested backups*, plus a runbook |

---

## IT-7 · Cybersecurity Fundamentals

**Level:** Advanced · **Access:** premium · **About 35 h** · **Prerequisites:** IT-2, IT-3

**Outcomes:** learners will be able to assess risks, explain common attacks and defences, apply cryptography correctly, harden systems, and respond to incidents within legal and ethical limits.

| Module | Lessons | Practice (legal labs only) |
| --- | --- | --- |
| 1. Security thinking | CIA triad · Risk and threat modelling · Laws, ethics and permission | Threat model a school app |
| 2. Attacks | Malware types · Social engineering · Password attacks | Analyse phishing headers |
| 3. Cryptography | Hashing vs encryption · Symmetric and asymmetric · TLS and certificates · Common mistakes | Verify file hashes; inspect a TLS certificate |
| 4. Identity | Authentication factors · Least privilege · Secrets management | Design access roles |
| 5. Network security | Firewalls, segmentation, VPN · Monitoring and IDS concepts | Firewall rules lab |
| 6. Web application security | OWASP Top 10 overview · Injection, XSS and broken access control explained | OWASP Juice Shop, run locally |
| 7. Hardening and response | Baselines and patching · Logging · Incident response lifecycle | Tabletop incident exercise |
| Final | Project: *Security assessment report for a fictional company* · Final assessment | |

Aligned with CompTIA Security+ topics. The course never teaches attacks against systems learners do not own or have written permission to test.

---

## IT-8 · Cloud Computing Fundamentals

**Level:** Advanced · **Access:** premium · **About 25 h** · **Prerequisites:** IT-3, IT-2

**Outcomes:** learners will be able to explain cloud models, deploy and secure compute, storage and networking on one provider, control costs, and run containers.

| Module | Lessons |
| --- | --- |
| 1. Cloud concepts | IaaS, PaaS, SaaS · Regions and availability · Shared responsibility |
| 2. Core services | Virtual machines · Object and block storage · Virtual networks |
| 3. Identity and security | IAM users, roles and policies · Secrets and keys |
| 4. Containers | Docker images, containers and Compose |
| 5. Cost and operations | Pricing models, budgets and alerts · Tagging |
| Final | Project: *Deploy a containerised app with storage and least-privilege access*, staying within a free tier |

Hands-on work uses one major provider's free tier. Learners are told how to set budget alerts before they create any resources.

---

## IT-9 · DevOps & Cloud Engineering (Professional capstone)

**Level:** Professional · **Access:** premium · **About 45 h** · **Prerequisites:** IT-6, IT-8, and Programming P-B2 (Git)

**Outcomes:** learners will be able to build CI/CD pipelines, manage infrastructure as code, operate containers in orchestration, and run services with observability and on-call practices.

Modules:
1. CI/CD pipelines
2. Infrastructure as code with Terraform
3. Kubernetes fundamentals
4. Observability (metrics, logs, traces)
5. Reliability practices (SLOs, incident reviews)
6. Security in pipelines

**Capstone:** design, deploy and operate a three-tier application with automated deploys, monitoring dashboards, alerts and a post-incident review. A mentor reviews it against a published rubric.

## Expert specialisations

These are taught through project briefs, reading lists and mentor review, not long video courses:
- **Network engineering:** routing protocols, enterprise design; aligned with CCNA/CCNP.
- **Security engineering:** detection engineering, application security, cloud security.
- **Cloud architecture:** multi-account design, resilience, cost optimisation.
