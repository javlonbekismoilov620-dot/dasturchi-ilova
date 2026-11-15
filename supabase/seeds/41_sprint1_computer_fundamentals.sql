-- Sprint 1 · Computer Fundamentals from Zero (English). Idempotent; existing rows keep IDs.
do $content$
declare
  c constant text := 'computer-fundamentals-from-zero';
  q uuid;
begin
  perform seed.ensure_module(c, 'Inside the machine', 'The parts that do the work: processor, memory, storage and ports.');
  perform seed.ensure_module(c, 'Staying safe and in control', 'How the operating system protects you, and how to protect your accounts.');

  perform seed.ensure_lesson(c, 'Inside the machine', 'Processor and memory: how a computer thinks', 'article', 10,
    'What the processor, RAM and storage really do — and why “more” is not always “faster”.',
$md$## Three parts that work together

In this lesson you will learn what the processor, memory and storage actually do, so you can understand any computer's specifications. Every time you open an app, these three parts work as a team:

1. The app's files are read from **storage**.
2. They are loaded into **memory (RAM)**, where they can be reached quickly.
3. The **processor (CPU)** follows the app's instructions, step by step.

## The processor (CPU)

The CPU repeats one simple cycle billions of times per second: **fetch** an instruction, **work out** what it means, **carry it out**.

- **Clock speed**, measured in gigahertz (GHz), is how many cycles happen each second. 3 GHz means about three billion cycles per second.
- **Cores** are independent workers inside one processor. A 6-core CPU can work on six streams of instructions at the same time.

More cores help when a job can be split into parts — exporting video, rendering 3D, compiling code or running many apps at once. Many everyday tasks run mainly on one core, so a CPU with fewer but faster cores can feel just as quick for web browsing and documents.

> [!NOTE]
> The **GPU** (graphics processor) has hundreds or thousands of small cores designed for doing the same calculation on many pixels at once. That is why it is so good at graphics, video and AI work.

## Memory (RAM)

RAM is the computer's **workspace**. Everything you have open right now — browser tabs, documents, the operating system itself — lives in RAM. It is very fast, but it is cleared when the power goes off.

When RAM is full, the operating system moves some data to storage to make room (a *page file* or *swap*). Storage is much slower than RAM, so the computer suddenly feels sluggish.

| Kind of use | Workable RAM | Comfortable RAM |
| --- | --- | --- |
| Web, documents, studying | 8 GB | 16 GB |
| Programming, design | 16 GB | 32 GB |
| Video editing, 3D, games | 16 GB | 32 GB or more |

## Storage

Storage keeps your files and apps when the computer is off. There are three common kinds:

- **HDD** (hard disk drive) — spinning magnetic disks. Cheap for large capacity, but slow and sensitive to knocks.
- **SATA SSD** — no moving parts and several times faster than an HDD.
- **NVMe SSD** — connects directly to the motherboard (usually in an *M.2* slot) and is the fastest common option.

An SSD makes the whole computer feel faster: it starts up in seconds and apps open quickly. For most people, an SSD matters more than a slightly faster processor.

## A worked example

You open a 50 MB photo in an editor. The photo is read from the **SSD**, loaded into **RAM**, the **CPU** runs the editor's instructions, the **GPU** helps apply a filter, and the result appears on the screen. If RAM is almost full, the computer has to keep swapping data to storage, and every click feels slow.

## Try it

Find the processor, RAM and storage of the computer you are using:

- **Windows:** **Settings → System → About**, and **Task Manager → Performance** (press **Ctrl + Shift + Esc**).
- **macOS:** **Apple menu → About This Mac**.

Write down the number of cores, the amount of RAM and the type and size of storage.

## Common mistakes

- Judging a processor by GHz alone. Cores and the processor's generation matter as much.
- Buying a lot of storage but too little RAM, so the computer slows down whenever several apps are open.
- Mixing up RAM and storage. When a phone is advertised with “128 GB”, that is storage, not RAM.

## Key terms

- **CPU / core** — the processor and one of its independent workers.
- **Clock speed (GHz)** — cycles per second, in billions.
- **RAM** — fast, temporary working memory.
- **SSD / HDD / NVMe** — kinds of permanent storage, from fastest (NVMe) to slowest (HDD).$md$);

  perform seed.ensure_lesson(c, 'Inside the machine', 'Ports, peripherals and reading a spec sheet', 'article', 10,
    'Connect devices with the right ports, and read a computer specification line by line.',
$md$## Peripherals: everything you plug in

A **peripheral** is a device connected to a computer from outside: a keyboard, mouse, monitor, printer, headphones or an external drive. By the end of this lesson you will recognise the common ports and be able to read a computer's specification sheet with confidence.

## Common ports

| Port | What it is used for |
| --- | --- |
| **USB-A** | The classic rectangular USB: mice, keyboards, flash drives |
| **USB-C** | Small reversible connector for data, charging and often video |
| **HDMI** | Video and sound to a monitor, TV or projector |
| **Ethernet (RJ-45)** | Wired network connection — more stable than Wi-Fi |
| **3.5 mm audio** | Wired headphones and microphones |
| **SD card slot** | Memory cards from cameras and drones |

> [!WARNING]
> Every USB-C port has the same shape, but not the same abilities. One port may charge and show video, another may only transfer data slowly. Check the specification or the small symbols next to the port (for example, the lightning bolt for Thunderbolt) before you buy cables and adapters.

## Wireless connections

- **Wi-Fi** connects to the internet without cables. Newer standards (Wi-Fi 6, 6E and 7) are faster and cope better with many devices in one place.
- **Bluetooth** connects nearby accessories such as wireless headphones, keyboards and mice.

## Reading a specification sheet

Here is a typical laptop specification, explained line by line:

| Specification | What it tells you |
| --- | --- |
| 8-core processor, up to 4.5 GHz | Good for multitasking and heavier work; “up to” is the short burst speed |
| 16 GB RAM | Comfortable for studying, office work and programming |
| 512 GB NVMe SSD | Fast storage; about 476 GB will be shown as usable |
| 14-inch, 1920×1200 display | Screen size measured diagonally, and the number of pixels |
| Integrated graphics | Fine for everyday work; limited for 3D and games |
| 2× USB-C, 1× USB-A, HDMI | Plenty of connections without adapters |
| Wi-Fi 6, Bluetooth 5.3 | Modern wireless standards |
| Battery up to 10 hours | Measured in light use; expect less in real life |

Why does 512 GB show as about 476 GB? Manufacturers count 1 GB as 1 000 000 000 bytes, while operating systems often count in units of 1 024. The operating system and recovery files also take some space.

## Matching a computer to a need

| Person | Focus on |
| --- | --- |
| Student writing and browsing | SSD, 8–16 GB RAM, a light laptop with good battery life |
| Video editor | Strong multi-core CPU, 32 GB RAM, large NVMe SSD, a dedicated GPU |
| Office worker | Reliable SSD, 16 GB RAM, good keyboard, enough ports for a monitor |

## Try it

Open the specification pages of two laptops sold in your area. For a student on a budget, decide which one you would choose, and write two sentences explaining why using the lines of the specification.

## Common mistakes

- Trusting “up to” numbers for battery life and speed as everyday values.
- Assuming every USB-C cable or port supports charging and video.
- Choosing a computer for its large storage while it has too little RAM.

## Key terms

- **Peripheral** — a device connected to the computer from outside.
- **Port** — a socket for connecting a cable.
- **USB-C** — a reversible connector whose abilities vary by device.
- **Specification (spec sheet)** — the list of a device's parts and features.$md$);

  perform seed.ensure_lesson(c, 'Inside the machine', 'Inside the machine: check', 'quiz', 5,
    'Five questions on processors, memory, storage and ports.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Inside the machine: check', 'Inside the machine check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'What does more RAM mainly help with?',
    'RAM is working space: more of it lets you keep more apps and files open without the computer slowing down.',
    array['Working on more things at once without slowing down', 'Storing more files permanently', 'A faster internet connection'],
    array[true, false, false],
    array[null, 'Permanent storage is the job of the SSD or HDD.', 'Internet speed depends on your connection, not RAM.']);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which type of storage is usually the fastest?',
    'NVMe SSDs connect directly to the motherboard and are the fastest common storage.',
    array['HDD', 'SATA SSD', 'NVMe SSD'], array[false, false, true],
    array['HDDs spin magnetic disks and are the slowest.', 'Faster than an HDD, but slower than NVMe.', null]);
  perform seed.ensure_question(q, 2, 'true_false', 'True or false: a processor with more cores is always faster for every task.',
    'False. More cores help when work can be split up; many everyday tasks depend mostly on one fast core.',
    array['True', 'False'], array[false, true],
    array['Many tasks cannot use extra cores.', null]);
  perform seed.ensure_question(q, 3, 'single_choice', 'A new laptop is advertised with 512 GB of storage, but the system shows about 476 GB. Why?',
    'Manufacturers count in thousands, operating systems often in units of 1 024, and the system itself uses some space.',
    array['Different ways of counting gigabytes, plus space used by the system', 'The laptop is faulty', 'A virus is hiding files'],
    array[true, false, false],
    array[null, 'This difference is normal on every computer.', 'The difference is expected and has nothing to do with viruses.']);
  perform seed.ensure_question(q, 4, 'multiple_choice', 'Depending on the device, what can a USB-C port carry? Select **all** that apply.',
    'USB-C can carry data, power and video — but each device decides which of these its ports support.',
    array['Data', 'Charging power', 'Video to a monitor', 'A Wi-Fi signal'], array[true, true, true, false],
    array[null, null, null, 'Wi-Fi is wireless; it does not travel through a USB-C port.']);

  perform seed.ensure_lesson(c, 'Working with files', 'Installing and removing software safely', 'article', 9,
    'Where to download apps, how installers work and how to uninstall cleanly.',
$md$## Where software should come from

In this lesson you will learn how to install and remove programs without picking up malware or unwanted extras. Safe sources, in order of preference:

1. **The official app store** of your system — Microsoft Store on Windows, the App Store on macOS. Apps there are checked before they are listed.
2. **The developer's official website** — for example, videolan.org for VLC or python.org for Python. Type the address yourself or check it carefully.
3. **A package manager** — a tool that installs software from trusted lists. You will meet these in later courses.

> [!WARNING]
> “Cracked” or pirated software is one of the most common ways malware spreads, and using it is illegal. If a program costs money, look for an official free version, an education discount or a free alternative.

## Red flags on download pages

- Several large “Download” buttons — usually advertisements leading elsewhere.
- A file that does not match what you expect (for example, a 1 MB file for a 300 MB program).
- A site that is not the developer's own domain.

## Installing on Windows

Windows installers are usually `.exe` or `.msi` files. When you run one:

- A **User Account Control** prompt asks whether the app may make changes. Allow it only for software you trust.
- Read every screen. Installers sometimes offer extra software such as browser toolbars — **untick these offers**.
- Choose the default install folder unless you have a reason to change it.

## Installing on macOS

Mac apps usually come as `.dmg` files. Open the file and drag the app into the **Applications** folder. If macOS warns that the developer cannot be verified, stop and check where the file came from instead of bypassing the warning.

## Keeping software updated

Updates fix security problems as well as adding features. Turn on automatic updates where available, and install updates for your browser and operating system promptly.

## Removing software

- **Windows:** **Settings → Apps → Installed apps**, choose the app, then **Uninstall**.
- **macOS:** drag the app from **Applications** to the **Trash**. Some apps include their own uninstaller — use it if there is one.

Uninstalling programs you no longer use frees space and removes software that would otherwise need updates.

## Try it

Install a free program from its official website — for example, the VLC media player from videolan.org. Open it once, then uninstall it using the steps above.

## Common mistakes

- Clicking the first search result, which is often an advertisement.
- Clicking **Next** on every installer screen without reading it.
- Leaving old, unused programs installed and out of date.

## Key terms

- **Installer** — a file that copies a program onto your computer and sets it up.
- **Malware** — software designed to harm you or your computer.
- **Uninstall** — to remove a program properly.
- **Update** — a new version that fixes problems or adds features.$md$);

  perform seed.ensure_lesson(c, 'Working with files', 'Backups and the cloud', 'article', 9,
    'The 3-2-1 backup rule, how cloud storage works and why sync is not the same as backup.',
$md$## Why backups matter

Sooner or later, every device fails, gets lost or is stolen — and people delete the wrong file by accident. In this lesson you will learn how to keep copies so that losing a device never means losing your work.

Common causes of data loss:

- A storage drive fails, often without warning.
- A laptop or phone is lost or stolen.
- A file is deleted or overwritten by mistake.
- **Ransomware** — malware that locks your files and demands payment.

## The 3-2-1 rule

Professionals follow a simple rule:

- **3** copies of important data (the original and two backups),
- on **2** different kinds of storage (for example, your laptop and an external drive),
- with **1** copy kept **off-site** (in the cloud or at another location).

If the house floods, the off-site copy survives. If the cloud account is locked, the external drive still has your files.

## Cloud storage

Services such as Google Drive, iCloud and OneDrive keep your files on their servers and make them available on all your devices. Most offer some free space.

> [!WARNING]
> **Sync is not a backup.** A synced folder copies every change everywhere — including deletions. If you delete a file on your laptop, it disappears from the cloud too. Use the service's version history or a separate backup to protect against this.

## Built-in backup tools

- **Windows:** **Settings → Accounts → Windows Backup**, and **File History** for keeping older versions of files on an external drive.
- **macOS:** **Time Machine** backs up the whole Mac to an external drive automatically.

## Test your backups

A backup you have never restored is only a hope. Every few months, restore one file from your backup to check that it works.

## A worked example

Aziza is a student with essays, photos and project files:

| Copy | Where | Kind of storage |
| --- | --- | --- |
| Original | Laptop SSD | Internal drive |
| Backup 1 | External drive, Time Machine weekly | External drive |
| Backup 2 | Cloud folder with version history | Off-site |

## Try it

Make a table like Aziza's for your own important files. Then switch on the built-in backup tool on your computer, or choose a cloud service.

## Common mistakes

- Treating a synced folder as a backup.
- Keeping the backup drive plugged in all the time, where ransomware can reach it too.
- Never testing whether files can actually be restored.

## Key terms

- **Backup** — a separate copy kept so you can restore lost data.
- **3-2-1 rule** — three copies, two kinds of storage, one off-site.
- **Sync** — keeping the same files identical on several devices.
- **Ransomware** — malware that locks files and demands payment.$md$);

  perform seed.ensure_lesson(c, 'Working with files', 'Working with files: check', 'quiz', 5,
    'Five questions on files, safe installs and backups.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Working with files: check', 'Working with files check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'What does the 3-2-1 backup rule say?',
    'Three copies, on two different kinds of storage, with one copy off-site.',
    array['3 copies, 2 kinds of storage, 1 copy off-site', '3 backups a day, 2 passwords, 1 cloud account', '3 folders, 2 drives, 1 computer'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'true_false', 'True or false: a synced cloud folder is a complete backup on its own.',
    'False. Sync copies deletions too; you need version history or a separate backup.',
    array['True', 'False'], array[false, true],
    array['If you delete a file, sync deletes it everywhere.', null]);
  perform seed.ensure_question(q, 2, 'single_choice', 'Where is the safest place to download a program?',
    'The official app store or the developer''s own website.',
    array['The official app store or the developer''s website', 'The first advert in the search results', 'A site offering a “cracked” version'],
    array[true, false, false],
    array[null, 'Adverts often lead to look-alike sites.', 'Cracked software is illegal and a common source of malware.']);
  perform seed.ensure_question(q, 3, 'single_choice', 'An installer offers to add a “free browser toolbar”. What should you do?',
    'Untick the extra offer; install only what you came for.',
    array['Untick the offer and continue', 'Accept it — it is free', 'Cancel and never install anything again'],
    array[true, false, false],
    array[null, 'Bundled extras are often unwanted or harmful.', 'You can install safely by reading each screen.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'Why should you not keep a backup drive plugged in all the time?',
    'Ransomware can lock files on every connected drive, including the backup.',
    array['Ransomware could lock the backup too', 'It makes the computer slower', 'The drive will run out of power'],
    array[true, false, false],
    array[null, 'A connected drive does not slow the computer down.', 'External drives do not have their own batteries to drain.']);

  perform seed.ensure_lesson(c, 'Staying safe and in control', 'What an operating system does', 'article', 9,
    'Users, permissions, updates and the tools that show what your computer is doing.',
$md$## The manager of the computer

You already know that the **operating system (OS)** is the main program that runs everything else. In this lesson you will see what it manages for you — and which of its settings keep you safe.

The OS has five main jobs:

1. **Hardware** — it talks to the processor, memory, storage and devices through drivers.
2. **Programs** — it starts apps, shares processor time between them and stops them.
3. **Files** — it organises storage into files and folders.
4. **Users and security** — it keeps each person's files separate and decides who may do what.
5. **Interface** — it gives you the desktop, windows, menus and touch gestures.

Common operating systems are Windows, macOS and Linux on computers, and Android and iOS on phones.

## Users and accounts

Each person who uses a computer should have their own **user account**, with their own files and settings.

- An **administrator** account can install software and change system settings.
- A **standard** account can use apps but needs an administrator's approval for system changes.

> [!TIP]
> Using a standard account for everyday work limits the damage if you open a harmful file by mistake: malware cannot change the system without asking.

## Permissions

Apps must ask before using sensitive things such as the camera, microphone, location, contacts or your files. Grant only what an app genuinely needs. A flashlight app has no reason to read your contacts.

- **Windows:** **Settings → Privacy & security**.
- **macOS:** **System Settings → Privacy & Security**.
- **Phones:** **Settings → Apps** (Android) or **Settings → Privacy & Security** (iOS).

## Updates

OS updates fix security holes that criminals actively use. Install them promptly, and restart when asked — many updates only finish after a restart.

## Seeing what is running

When an app freezes, the OS can show you what is happening:

- **Windows:** **Task Manager** (**Ctrl + Shift + Esc**) lists running apps and how much CPU and memory each uses. Select a frozen app and choose **End task**.
- **macOS:** **Activity Monitor** (in **Applications → Utilities**) does the same; **Force Quit** stops a frozen app (**Option + Command + Esc**).

## Try it

1. Find which version of your operating system you are running.
2. Open the privacy settings and check which apps may use your camera and microphone.
3. Open Task Manager or Activity Monitor and find the app using the most memory.

## Common mistakes

- Postponing updates for weeks.
- Using an administrator account for everything.
- Allowing every permission an app asks for without thinking.

## Key terms

- **Operating system (OS)** — the program that manages the hardware and runs all other programs.
- **Administrator / standard account** — an account that can or cannot change the system.
- **Permission** — an app's right to use something sensitive, such as the camera.
- **Task Manager / Activity Monitor** — tools that show running programs.$md$);

  perform seed.ensure_lesson(c, 'Staying safe and in control', 'Passwords, two-factor authentication and phishing', 'article', 10,
    'Strong passwords, a second factor for every important account, and how to spot a scam.',
$md$## Your accounts are your keys

Email, messengers, banking and study accounts hold a large part of your life. In this lesson you will learn three habits that stop most account thefts: strong unique passwords, two-factor authentication and recognising phishing.

## Strong passwords

- **Length beats complexity.** A long passphrase of four or more random words, such as `river-lamp-orange-cloud`, is far harder to guess than `P@ss1`.
- **One password per account.** When one website is hacked, criminals try the same email and password everywhere else.
- **Use a password manager.** It creates and remembers strong, unique passwords, so you only need to remember one main password. Well-known managers are built into browsers and phones, and standalone apps exist too.

> [!WARNING]
> Never use personal information — your name, birthday or phone number — in a password. It is the first thing attackers try.

## Two-factor authentication (2FA)

2FA means logging in needs **two different proofs**: something you **know** (your password) and something you **have** (your phone or a security key).

- An **authenticator app** shows a new six-digit code every 30 seconds — the recommended option.
- An **SMS code** is weaker, because phone numbers can be hijacked, but it is still much better than no second factor.
- **Passkeys** let you sign in with your fingerprint or face instead of a password, and cannot be phished.

Turn on 2FA first for your email account — it can reset all your other passwords.

## Phishing

**Phishing** is a message that pretends to be from someone you trust — a bank, a delivery company, a messenger's support team — to trick you into giving away a password or code.

Warning signs:

- **Urgency or threats:** “Your card will be blocked in one hour.”
- **A link that does not match:** the text says your bank, but the address is something like `bank-secure-login.example`.
- **A request for a one-time code.** No real bank or messenger will ever ask you to tell them a code you received by SMS.

> [!TIP]
> If a message worries you, do not use its links or phone numbers. Open the official app or call the number printed on your bank card.

## If you clicked a phishing link

1. Change the password of that account immediately (and anywhere you reused it).
2. Turn on 2FA if it was off.
3. Check the account's list of active sessions or devices and sign out ones you do not recognise.
4. If money or a bank card is involved, call your bank straight away.

## Try it

Turn on two-factor authentication for your main email account using an authenticator app. Then look at a recent message from a company and check the real address behind its links.

## Common mistakes

- Reusing one password for several sites.
- Telling a one-time code to someone on the phone who “works at the bank”.
- Trusting a message because it shows a familiar logo.

## Key terms

- **Passphrase** — a long password made of several words.
- **Password manager** — an app that creates and stores unique passwords.
- **Two-factor authentication (2FA)** — logging in with two different proofs of identity.
- **Phishing** — a fake message designed to steal passwords, codes or money.$md$);

  perform seed.ensure_lesson(c, 'Staying safe and in control', 'Staying safe: check', 'quiz', 5,
    'Five questions on accounts, permissions, passwords and phishing.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Staying safe: check', 'Staying safe check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which password is the strongest?',
    'Length matters most: a passphrase of several random words beats a short complex password.',
    array['`river-lamp-orange-cloud`', '`P@ss1`', '`Aziza2008`'], array[true, false, false],
    array[null, 'Short passwords are guessed quickly, even with symbols.', 'Names and years are the first things attackers try.']);
  perform seed.ensure_question(q, 1, 'true_false', 'True or false: it is safe to read out an SMS code to a caller who says they work at your bank and knows your name.',
    'False. Banks never ask for one-time codes. Hang up and call the number on your card.',
    array['True', 'False'], array[false, true],
    array['Knowing your name proves nothing; this is a classic scam.', null]);
  perform seed.ensure_question(q, 2, 'single_choice', 'Why use a standard (non-administrator) account for everyday work?',
    'Malware and mistakes cannot change the system without an administrator''s approval.',
    array['It limits the damage from malware and mistakes', 'It makes the internet faster', 'It saves battery'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'A flashlight app asks for access to your contacts. What should you do?',
    'Grant only what an app needs; a flashlight does not need your contacts.',
    array['Deny it', 'Allow it — apps need everything', 'Allow it once to see what happens'],
    array[true, false, false],
    array[null, 'Apps should get only the permissions they need.', 'Once allowed, the app can copy your contacts.']);
  perform seed.ensure_question(q, 4, 'multiple_choice', 'Which are warning signs of phishing? Select **all** that apply.',
    'Urgency, mismatched links and requests for codes are classic signs.',
    array['An urgent threat, such as “your card will be blocked”', 'A link whose address does not match the company', 'A request for a one-time code', 'A message you expected, from a known contact, with ordinary content'],
    array[true, true, true, false],
    array[null, null, null, 'Expected, ordinary messages are not a warning sign in themselves.']);

  -- Project and extended final assessment ---------------------------------------------------
  perform seed.ensure_lesson(c, 'Final assessment', 'Project: set up and secure a computer', 'project', 45,
    'Recommend, set up and protect a computer for a real person, and explain your choices.',
$md$## Your project

A relative or friend needs a computer for study or work. Prepare a short plan, as an IT professional would, that covers choosing, setting up and protecting it.

### What to deliver

1. **Who it is for** — the person, what they will use the computer for, and the budget.
2. **Specification** — processor, RAM, storage and ports, with one sentence explaining each choice.
3. **Setup plan** — user accounts (administrator and standard), updates, and the software to install from official sources.
4. **Backup plan** — which files matter and how the 3-2-1 rule is met.
5. **Security plan** — password manager, two-factor authentication for key accounts, and three phishing warning signs you will teach them.

### How to submit

Write your plan in the text box (about one page), upload it as a document, or share a link to it.

> [!NOTE]
> A reviewer checks your plan against the rubric and leaves feedback. You can improve it and resubmit.$md$,
    'published', false, 50);
  perform seed.ensure_assignment(c, 'Project: set up and secure a computer', 'Set up and secure a computer',
    'Write a one-page plan to choose, set up, back up and secure a computer for a real person.',
$r$| Criterion | Points |
| --- | --- |
| Specification fits the person and budget, with a reason for each part | 25 |
| Setup plan: accounts, updates and software from official sources | 20 |
| Backup plan that meets the 3-2-1 rule | 25 |
| Security plan: passwords, 2FA and phishing awareness | 20 |
| Clear, well-organised writing | 10 |$r$);

  q := seed.quiz_id(c, 'Computer Fundamentals — final assessment');
  perform seed.ensure_question(q, 4, 'single_choice', 'What is RAM used for?',
    'RAM is fast, temporary working memory for whatever is open right now.',
    array['Temporary working space for open apps and files', 'Keeping files when the computer is off', 'Connecting to Wi-Fi'],
    array[true, false, false],
    array[null, 'That is storage (SSD or HDD).', 'Wi-Fi is handled by the network adapter.']);
  perform seed.ensure_question(q, 5, 'single_choice', 'Which is the safest habit when installing software?',
    'Use official stores or the developer''s website and read each installer screen.',
    array['Download from official sources and read each installer screen', 'Use the first download button you see', 'Install cracked versions of paid apps'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'true_false', 'True or false: following the 3-2-1 rule, one copy of your data should be kept off-site.',
    'True — an off-site copy (for example, in the cloud) survives fire, flood or theft at home.',
    array['True', 'False'], array[true, false], null);
  perform seed.ensure_question(q, 7, 'single_choice', 'What is two-factor authentication?',
    'Signing in with two different proofs, such as a password and a code from your phone.',
    array['Signing in with a password plus a second proof, such as a phone code', 'Using two different passwords', 'Logging in on two devices'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 8, 'single_choice', 'You get a message: “Your card is blocked — send us the SMS code to unlock it.” What do you do?',
    'Never share one-time codes. Contact the bank through its official app or the number on your card.',
    array['Ignore the message and contact the bank through official channels', 'Send the code quickly before the card is blocked', 'Reply asking whether it is real'],
    array[true, false, false],
    array[null, 'Sharing the code gives the scammer access.', 'Replying confirms your number is active; use official channels instead.']);
  perform seed.ensure_question(q, 9, 'multiple_choice', 'Which of these are jobs of an operating system? Select **all** that apply.',
    'The OS manages hardware, runs programs, organises files and controls users and permissions.',
    array['Managing hardware', 'Running and stopping programs', 'Controlling user accounts and permissions', 'Designing websites'],
    array[true, true, true, false],
    array[null, null, null, 'Websites are designed by people using applications.']);

  perform seed.order_modules(c, array['What a computer really is', 'Inside the machine', 'Working with files', 'Staying safe and in control', 'Final assessment']);
  perform seed.order_lessons(c, 'Working with files', array['Files, folders and paths', 'Installing and removing software safely', 'Backups and the cloud', 'Working with files: check']);
  perform seed.order_lessons(c, 'Inside the machine', array['Processor and memory: how a computer thinks', 'Ports, peripherals and reading a spec sheet', 'Inside the machine: check']);
  perform seed.order_lessons(c, 'Staying safe and in control', array['What an operating system does', 'Passwords, two-factor authentication and phishing', 'Staying safe: check']);
  perform seed.order_lessons(c, 'Final assessment', array['Project: set up and secure a computer', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'computer-fundamentals-from-zero';
begin
  perform seed.tr_module(c, 'Inside the machine', 'uz', 'Kompyuter ichida',
    'Ishni bajaradigan qismlar: protsessor, operativ xotira, doimiy xotira va portlar.');
  perform seed.tr_module(c, 'Staying safe and in control', 'uz', 'Xavfsizlik va nazorat',
    'Operatsion tizim sizni qanday himoya qiladi va hisoblaringizni qanday himoya qilish kerak.');

  perform seed.tr_lesson(c, 'Processor and memory: how a computer thinks', 'uz', 'Protsessor va xotira: kompyuter qanday “fikrlaydi”',
    'Protsessor, operativ xotira va doimiy xotira aslida nima qiladi — va nega “koʻproq” har doim ham “tezroq” degani emas.',
$md$## Birgalikda ishlaydigan uchta qism

Bu darsda protsessor, operativ xotira va doimiy xotira aslida nima qilishini bilib olasiz — shunda istalgan kompyuterning texnik tavsifini tushuna olasiz. Har safar ilovani ochganingizda bu uch qism jamoa boʻlib ishlaydi:

1. Ilova fayllari **doimiy xotira**dan oʻqiladi.
2. Ular tez murojaat qilish mumkin boʻlgan **operativ xotira (RAM)** ga yuklanadi.
3. **Protsessor (CPU)** ilovaning koʻrsatmalarini qadamma-qadam bajaradi.

## Protsessor (CPU)

Protsessor har soniyada milliardlab marta bitta oddiy siklni takrorlaydi: koʻrsatmani **oladi**, uning maʼnosini **aniqlaydi** va uni **bajaradi**.

- **Takt chastotasi** gigagerts (GHz) bilan oʻlchanadi va har soniyada nechta sikl bajarilishini bildiradi. 3 GHz — soniyasiga taxminan uch milliard sikl degani.
- **Yadrolar** — bitta protsessor ichidagi mustaqil “ishchilar”. 6 yadroli protsessor bir vaqtning oʻzida oltita koʻrsatmalar oqimi ustida ishlay oladi.

Koʻp yadro ishni qismlarga boʻlish mumkin boʻlganda yordam beradi: videoni eksport qilish, 3D render qilish, kodni kompilyatsiya qilish yoki bir vaqtda koʻp ilova bilan ishlash. Koʻplab kundalik vazifalar asosan bitta yadroda bajariladi, shuning uchun yadrolari kamroq, lekin tezroq protsessor internetda ishlash va hujjatlar uchun xuddi shunday tez tuyulishi mumkin.

> [!NOTE]
> **GPU** (grafik protsessor) bir xil hisob-kitobni koʻplab piksellar uchun bir vaqtda bajarishga moʻljallangan yuzlab yoki minglab kichik yadrolarga ega. Shu sababli u grafika, video va sunʼiy intellekt bilan ishlashda juda kuchli.

## Operativ xotira (RAM)

RAM — kompyuterning **ish stoli**. Hozir ochiq turgan hamma narsa — brauzer yorliqlari, hujjatlar, hatto operatsion tizimning oʻzi — RAMda joylashadi. U juda tez, ammo elektr oʻchganda tozalanadi.

RAM toʻlib qolganda operatsion tizim joy boʻshatish uchun maʼlumotlarning bir qismini doimiy xotiraga koʻchiradi (*page file* yoki *swap*). Doimiy xotira RAMdan ancha sekin, shuning uchun kompyuter birdan sekinlashib qoladi.

| Foydalanish turi | Yetarli RAM | Qulay RAM |
| --- | --- | --- |
| Internet, hujjatlar, oʻqish | 8 GB | 16 GB |
| Dasturlash, dizayn | 16 GB | 32 GB |
| Video montaj, 3D, oʻyinlar | 16 GB | 32 GB va undan koʻp |

## Doimiy xotira

Doimiy xotira kompyuter oʻchiq boʻlganda ham fayllaringiz va ilovalaringizni saqlaydi. Uning uchta keng tarqalgan turi bor:

- **HDD** (qattiq disk) — aylanuvchi magnit disklar. Katta hajm uchun arzon, lekin sekin va zarbalarga sezgir.
- **SATA SSD** — harakatlanuvchi qismlari yoʻq va HDD dan bir necha barobar tez.
- **NVMe SSD** — bevosita ona plataga ulanadi (odatda *M.2* uyasiga) va eng tez keng tarqalgan variant hisoblanadi.

SSD butun kompyuterni tezroq his qildiradi: u bir necha soniyada ishga tushadi, ilovalar tez ochiladi. Koʻpchilik uchun SSD biroz tezroq protsessordan muhimroq.

## Ishlangan misol

Siz 50 MB hajmli fotosuratni muharrirda ochasiz. Surat **SSD** dan oʻqiladi, **RAM** ga yuklanadi, **CPU** muharrirning koʻrsatmalarini bajaradi, **GPU** filtr qoʻllashda yordam beradi va natija ekranda paydo boʻladi. Agar RAM deyarli toʻla boʻlsa, kompyuter maʼlumotlarni doimiy xotiraga qayta-qayta koʻchirishga majbur boʻladi va har bir bosish sekin bajariladi.

## Oʻzingiz sinab koʻring

Foydalanayotgan kompyuteringizning protsessori, RAMi va doimiy xotirasini toping:

- **Windows:** **Settings → System → About** hamda **Task Manager → Performance** (**Ctrl + Shift + Esc** ni bosing).
- **macOS:** **Apple menyusi → About This Mac**.

Yadrolar sonini, RAM hajmini hamda doimiy xotiraning turi va hajmini yozib oling.

## Keng tarqalgan xatolar

- Protsessorni faqat GHz boʻyicha baholash. Yadrolar soni va protsessor avlodi ham shunchalik muhim.
- Koʻp doimiy xotira, lekin juda kam RAM sotib olish — natijada bir nechta ilova ochilganda kompyuter sekinlashadi.
- RAM va doimiy xotirani chalkashtirish. Telefon “128 GB” deb reklama qilinganda, bu RAM emas, doimiy xotira.

## Asosiy atamalar

- **CPU / yadro** — protsessor va uning mustaqil “ishchilaridan” biri.
- **Takt chastotasi (GHz)** — soniyadagi sikllar soni, milliardlarda.
- **RAM** — tezkor, vaqtinchalik ishchi xotira.
- **SSD / HDD / NVMe** — doimiy xotira turlari, eng tezidan (NVMe) eng sekiniga (HDD) qadar.$md$);

  perform seed.tr_lesson(c, 'Ports, peripherals and reading a spec sheet', 'uz', 'Portlar, tashqi qurilmalar va texnik tavsifni oʻqish',
    'Qurilmalarni toʻgʻri portlarga ulang va kompyuter texnik tavsifini qatorma-qator oʻqing.',
$md$## Tashqi qurilmalar: ulanadigan hamma narsa

**Tashqi qurilma** (*peripheral*) — kompyuterga tashqaridan ulanadigan qurilma: klaviatura, sichqoncha, monitor, printer, quloqchin yoki tashqi disk. Dars oxirida keng tarqalgan portlarni taniysiz va kompyuterning texnik tavsifini ishonch bilan oʻqiy olasiz.

## Keng tarqalgan portlar

| Port | Nima uchun ishlatiladi |
| --- | --- |
| **USB-A** | Klassik toʻrtburchak USB: sichqoncha, klaviatura, fleshka |
| **USB-C** | Maʼlumot, quvvatlash va koʻpincha video uchun kichik, ikki tomonlama ulagich |
| **HDMI** | Monitor, televizor yoki proyektorga tasvir va ovoz uzatish |
| **Ethernet (RJ-45)** | Simli tarmoq ulanishi — Wi-Fi ga qaraganda barqarorroq |
| **3.5 mm audio** | Simli quloqchin va mikrofonlar |
| **SD karta uyasi** | Kamera va dronlardagi xotira kartalari |

> [!WARNING]
> Barcha USB-C portlar shakli bir xil, ammo imkoniyatlari har xil. Bir port quvvatlay oladi va tasvir chiqaradi, boshqasi esa faqat sekin maʼlumot uzatishi mumkin. Kabel va adapterlar sotib olishdan oldin texnik tavsifni yoki port yonidagi kichik belgilarni (masalan, Thunderbolt uchun chaqmoq belgisini) tekshiring.

## Simsiz ulanishlar

- **Wi-Fi** internetga simsiz ulanadi. Yangi standartlar (Wi-Fi 6, 6E va 7) tezroq va bir joydagi koʻplab qurilmalar bilan yaxshiroq ishlaydi.
- **Bluetooth** simsiz quloqchin, klaviatura va sichqoncha kabi yaqin atrofdagi qurilmalarni ulaydi.

## Texnik tavsifni oʻqish

Quyida odatiy noutbuk texnik tavsifi qatorma-qator tushuntirilgan:

| Tavsif | Nimani bildiradi |
| --- | --- |
| 8 yadroli protsessor, 4.5 GHz gacha | Bir vaqtda koʻp ish va ogʻirroq vazifalar uchun yaxshi; “gacha” — qisqa muddatli eng yuqori tezlik |
| 16 GB RAM | Oʻqish, ofis ishlari va dasturlash uchun qulay |
| 512 GB NVMe SSD | Tez doimiy xotira; foydalanish uchun taxminan 476 GB koʻrsatiladi |
| 14 dyuymli, 1920×1200 ekran | Diagonal boʻyicha oʻlchangan ekran hajmi va piksellar soni |
| Integratsiyalashgan grafika | Kundalik ishlar uchun yetarli; 3D va oʻyinlar uchun cheklangan |
| 2× USB-C, 1× USB-A, HDMI | Adaptersiz yetarlicha ulanish imkoniyati |
| Wi-Fi 6, Bluetooth 5.3 | Zamonaviy simsiz standartlar |
| Batareya 10 soatgacha | Yengil foydalanishda oʻlchangan; amalda kamroq boʻladi |

Nega 512 GB taxminan 476 GB boʻlib koʻrinadi? Ishlab chiqaruvchilar 1 GB ni 1 000 000 000 bayt deb hisoblaydi, operatsion tizimlar esa koʻpincha 1 024 lik birliklarda hisoblaydi. Operatsion tizim va tiklash fayllari ham biroz joy egallaydi.

## Kompyuterni ehtiyojga moslash

| Kim uchun | Nimaga eʼtibor berish kerak |
| --- | --- |
| Matn yozadigan va internetdan foydalanadigan talaba | SSD, 8–16 GB RAM, batareyasi yaxshi yengil noutbuk |
| Video montajchi | Kuchli koʻp yadroli protsessor, 32 GB RAM, katta NVMe SSD, alohida videokarta |
| Ofis xodimi | Ishonchli SSD, 16 GB RAM, qulay klaviatura, monitor uchun yetarli portlar |

## Oʻzingiz sinab koʻring

Hududingizda sotiladigan ikkita noutbukning texnik tavsif sahifalarini oching. Byudjeti cheklangan talaba uchun qaysi birini tanlashingizni hal qiling va texnik tavsif qatorlariga tayanib, sababini ikki gap bilan yozing.

## Keng tarqalgan xatolar

- Batareya va tezlik boʻyicha “gacha” raqamlarini kundalik qiymat deb ishonish.
- Har qanday USB-C kabel yoki port quvvatlash va tasvir uzatishni qoʻllab-quvvatlaydi deb oʻylash.
- RAMi juda kam boʻlsa-da, doimiy xotirasi katta boʻlgani uchun kompyuterni tanlash.

## Asosiy atamalar

- **Tashqi qurilma** — kompyuterga tashqaridan ulanadigan qurilma.
- **Port** — kabel ulash uchun uya.
- **USB-C** — imkoniyatlari qurilmaga qarab farq qiladigan ikki tomonlama ulagich.
- **Texnik tavsif** (*specification*) — qurilmaning qismlari va imkoniyatlari roʻyxati.$md$);

  perform seed.tr_lesson(c, 'Inside the machine: check', 'uz', 'Kompyuter ichida: bilimni tekshirish',
    'Protsessor, xotira, doimiy xotira va portlar boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Inside the machine check', 'uz', '“Kompyuter ichida” moduli boʻyicha test');
  perform seed.tr_question(c, 'Inside the machine check', 0, 'uz', 'Koʻproq RAM asosan nimaga yordam beradi?',
    'RAM — ishchi maydon: u koʻproq boʻlsa, kompyuter sekinlashmasdan koʻproq ilova va fayllarni ochiq tutish mumkin.',
    array['Bir vaqtda koʻp ish bilan sekinlashmasdan ishlashga', 'Fayllarni uzoq muddat koʻproq saqlashga', 'Internetning tezroq ishlashiga'],
    array[null, 'Uzoq muddat saqlash — SSD yoki HDD vazifasi.', 'Internet tezligi RAMga emas, ulanishingizga bogʻliq.']);
  perform seed.tr_question(c, 'Inside the machine check', 1, 'uz', 'Odatda doimiy xotiraning qaysi turi eng tez?',
    'NVMe SSD bevosita ona plataga ulanadi va eng tez keng tarqalgan doimiy xotira hisoblanadi.',
    array['HDD', 'SATA SSD', 'NVMe SSD'],
    array['HDD magnit disklarni aylantiradi va eng sekini hisoblanadi.', 'HDD dan tez, lekin NVMe dan sekin.', null]);
  perform seed.tr_question(c, 'Inside the machine check', 2, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: yadrolari koʻproq protsessor har qanday vazifada har doim tezroq ishlaydi.',
    'Notoʻgʻri. Koʻp yadro ishni boʻlish mumkin boʻlganda yordam beradi; koʻplab kundalik vazifalar asosan bitta tez yadroga bogʻliq.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array['Koʻplab vazifalar qoʻshimcha yadrolardan foydalana olmaydi.', null]);
  perform seed.tr_question(c, 'Inside the machine check', 3, 'uz', 'Yangi noutbuk 512 GB doimiy xotira bilan reklama qilingan, ammo tizim taxminan 476 GB koʻrsatadi. Nega?',
    'Ishlab chiqaruvchilar mingliklarda, operatsion tizimlar esa koʻpincha 1 024 lik birliklarda hisoblaydi, tizimning oʻzi ham biroz joy egallaydi.',
    array['Gigabaytlar har xil usulda hisoblanadi, ustiga tizim ham joy egallaydi', 'Noutbuk nosoz', 'Virus fayllarni yashirmoqda'],
    array[null, 'Bu farq har qanday kompyuterda odatiy hol.', 'Bu kutilgan farq, uning viruslarga aloqasi yoʻq.']);
  perform seed.tr_question(c, 'Inside the machine check', 4, 'uz', 'Qurilmaga qarab USB-C porti nimalarni uzata oladi? Mos keladigan **barcha** variantlarni belgilang.',
    'USB-C maʼlumot, quvvat va tasvir uzata oladi — ammo uning portlari qaysilarini qoʻllab-quvvatlashini har bir qurilmaning oʻzi belgilaydi.',
    array['Maʼlumot', 'Quvvatlash toki', 'Monitorga tasvir', 'Wi-Fi signali'],
    array[null, null, null, 'Wi-Fi simsiz ishlaydi; u USB-C porti orqali uzatilmaydi.']);

  perform seed.tr_lesson(c, 'Installing and removing software safely', 'uz', 'Dasturlarni xavfsiz oʻrnatish va oʻchirish',
    'Ilovalarni qayerdan yuklab olish, oʻrnatuvchilar qanday ishlashi va dasturni toʻliq oʻchirish.',
$md$## Dasturlar qayerdan olinishi kerak

Bu darsda dasturlarni zararli yoki keraksiz qoʻshimchalarsiz oʻrnatish va oʻchirishni oʻrganasiz. Xavfsiz manbalar, afzallik tartibida:

1. Tizimingizning **rasmiy ilovalar doʻkoni** — Windowsda Microsoft Store, macOSda App Store. U yerdagi ilovalar roʻyxatga kiritilishidan oldin tekshiriladi.
2. **Ishlab chiqaruvchining rasmiy sayti** — masalan, VLC uchun videolan.org yoki Python uchun python.org. Manzilni oʻzingiz yozing yoki diqqat bilan tekshiring.
3. **Paketlar menejeri** — dasturlarni ishonchli roʻyxatlardan oʻrnatadigan vosita. Ular bilan keyingi kurslarda tanishasiz.

> [!WARNING]
> “Buzilgan” (*cracked*) yoki qaroqchilik yoʻli bilan tarqatilgan dasturlar zararli dasturlar tarqalishining eng keng tarqalgan yoʻllaridan biri, ulardan foydalanish esa qonunga xilof. Agar dastur pullik boʻlsa, uning rasmiy bepul versiyasini, taʼlim uchun chegirmani yoki bepul muqobilini qidiring.

## Yuklab olish sahifalaridagi xavf belgilari

- Bir nechta katta “Download” tugmasi — odatda boshqa joyga olib boradigan reklamalar.
- Kutilganga mos kelmaydigan fayl (masalan, 300 MB lik dastur oʻrniga 1 MB lik fayl).
- Ishlab chiqaruvchining oʻz domeni boʻlmagan sayt.

## Windowsda oʻrnatish

Windows oʻrnatuvchilari odatda `.exe` yoki `.msi` fayllari boʻladi. Ulardan birini ishga tushirganingizda:

- **User Account Control** (foydalanuvchi hisoblarini boshqarish) oynasi ilovaga oʻzgartirishlar kiritishga ruxsat berish-bermaslikni soʻraydi. Faqat ishonchli dasturlarga ruxsat bering.
- Har bir oynani oʻqing. Oʻrnatuvchilar baʼzan brauzer panellari kabi qoʻshimcha dasturlarni taklif qiladi — **bu takliflardan belgini olib tashlang**.
- Biror sababingiz boʻlmasa, standart oʻrnatish papkasini tanlang.

## macOSda oʻrnatish

Mac ilovalari odatda `.dmg` fayllari koʻrinishida keladi. Faylni oching va ilovani **Applications** papkasiga torting. Agar macOS ishlab chiquvchini tasdiqlab boʻlmasligi haqida ogohlantirsa, ogohlantirishni chetlab oʻtish oʻrniga toʻxtang va fayl qayerdan kelganini tekshiring.

## Dasturlarni yangilab turish

Yangilanishlar yangi imkoniyatlar qoʻshish bilan birga xavfsizlik muammolarini ham tuzatadi. Imkon boʻlgan joyda avtomatik yangilanishni yoqing, brauzer va operatsion tizim yangilanishlarini kechiktirmasdan oʻrnating.

## Dasturlarni oʻchirish

- **Windows:** **Settings → Apps → Installed apps** boʻlimida ilovani tanlang, soʻngra **Uninstall** ni bosing.
- **macOS:** ilovani **Applications** papkasidan **Trash** (savat) ga torting. Baʼzi ilovalarning oʻz oʻchirish dasturi boʻladi — agar bor boʻlsa, undan foydalaning.

Foydalanmaydigan dasturlarni oʻchirish joy boʻshatadi va aks holda yangilab turish kerak boʻladigan dasturlardan xalos qiladi.

## Oʻzingiz sinab koʻring

Bepul dasturni uning rasmiy saytidan oʻrnating — masalan, VLC media pleyerini videolan.org saytidan. Uni bir marta oching, soʻngra yuqoridagi qadamlar bilan oʻchiring.

## Keng tarqalgan xatolar

- Koʻpincha reklama boʻlib chiqadigan birinchi qidiruv natijasini bosish.
- Oʻrnatuvchining har bir oynasida oʻqimasdan **Next** ni bosish.
- Eski, foydalanilmaydigan dasturlarni yangilamasdan oʻrnatilgan holda qoldirish.

## Asosiy atamalar

- **Oʻrnatuvchi** (*installer*) — dasturni kompyuteringizga koʻchiradigan va sozlaydigan fayl.
- **Zararli dastur** (*malware*) — sizga yoki kompyuteringizga zarar yetkazish uchun yaratilgan dastur.
- **Oʻchirish** (*uninstall*) — dasturni toʻgʻri usulda olib tashlash.
- **Yangilanish** (*update*) — muammolarni tuzatadigan yoki imkoniyat qoʻshadigan yangi versiya.$md$);

  perform seed.tr_lesson(c, 'Backups and the cloud', 'uz', 'Zaxira nusxalar va bulut',
    '3-2-1 zaxiralash qoidasi, bulutli xotira qanday ishlashi va nega sinxronlash zaxira nusxa bilan bir xil emasligi.',
$md$## Zaxira nusxalar nega muhim

Ertami-kechmi har qanday qurilma buziladi, yoʻqoladi yoki oʻgʻirlanadi — odamlar esa notoʻgʻri faylni bilmasdan oʻchirib yuboradi. Bu darsda qurilmani yoʻqotish hech qachon ishingizni yoʻqotish degani boʻlmasligi uchun nusxalarni qanday saqlashni oʻrganasiz.

Maʼlumot yoʻqolishining keng tarqalgan sabablari:

- Doimiy xotira qurilmasi koʻpincha ogohlantirishsiz ishdan chiqadi.
- Noutbuk yoki telefon yoʻqoladi yoki oʻgʻirlanadi.
- Fayl xato tufayli oʻchirib yuboriladi yoki ustidan yoziladi.
- **Ransomware** (toʻlov talab qiluvchi dastur) — fayllaringizni qulflab, pul talab qiladigan zararli dastur.

## 3-2-1 qoidasi

Mutaxassislar oddiy qoidaga amal qiladi:

- muhim maʼlumotlarning **3** nusxasi (asl nusxa va ikkita zaxira),
- **2** xil turdagi xotirada (masalan, noutbukingiz va tashqi disk),
- **1** nusxa **boshqa joyda** (bulutda yoki boshqa manzilda) saqlanadi.

Agar uyni suv bossa, boshqa joydagi nusxa saqlanib qoladi. Agar bulut hisobi bloklansa, fayllaringiz tashqi diskda baribir boʻladi.

## Bulutli xotira

Google Drive, iCloud va OneDrive kabi xizmatlar fayllaringizni oʻz serverlarida saqlaydi va ularni barcha qurilmalaringizda ochish imkonini beradi. Aksariyati maʼlum hajmdagi joyni bepul beradi.

> [!WARNING]
> **Sinxronlash — zaxira nusxa emas.** Sinxronlangan papka har bir oʻzgarishni hamma joyga koʻchiradi — oʻchirishlarni ham. Noutbukingizda faylni oʻchirsangiz, u bulutdan ham yoʻqoladi. Bunga qarshi xizmatning versiyalar tarixidan yoki alohida zaxira nusxadan foydalaning.

## Oʻrnatilgan zaxiralash vositalari

- **Windows:** **Settings → Accounts → Windows Backup** hamda fayllarning eski versiyalarini tashqi diskda saqlash uchun **File History**.
- **macOS:** **Time Machine** butun Mac kompyuterni tashqi diskka avtomatik zaxiralaydi.

## Zaxira nusxalaringizni tekshiring

Hech qachon tiklab koʻrilmagan zaxira nusxa — shunchaki umid. Har bir necha oyda zaxira nusxadan bitta faylni tiklab, uning ishlashini tekshiring.

## Ishlangan misol

Aziza — insholar, fotosuratlar va loyiha fayllari bor talaba:

| Nusxa | Qayerda | Xotira turi |
| --- | --- | --- |
| Asl nusxa | Noutbuk SSD si | Ichki disk |
| 1-zaxira | Tashqi disk, haftada bir marta Time Machine | Tashqi disk |
| 2-zaxira | Versiyalar tarixi bor bulut papkasi | Boshqa joyda |

## Oʻzingiz sinab koʻring

Muhim fayllaringiz uchun Azizanikiga oʻxshash jadval tuzing. Keyin kompyuteringizdagi oʻrnatilgan zaxiralash vositasini yoqing yoki bulut xizmatini tanlang.

## Keng tarqalgan xatolar

- Sinxronlangan papkani zaxira nusxa deb hisoblash.
- Zaxira diskni doim ulangan holda qoldirish — u yerga ransomware ham yetib boradi.
- Fayllarni haqiqatan ham tiklash mumkinligini hech qachon tekshirmaslik.

## Asosiy atamalar

- **Zaxira nusxa** (*backup*) — yoʻqolgan maʼlumotni tiklash uchun alohida saqlanadigan nusxa.
- **3-2-1 qoidasi** — uchta nusxa, ikki xil xotira, bittasi boshqa joyda.
- **Sinxronlash** (*sync*) — bir nechta qurilmadagi fayllarni bir xil holatda saqlash.
- **Ransomware** — fayllarni qulflab, pul talab qiladigan zararli dastur.$md$);

  perform seed.tr_lesson(c, 'Working with files: check', 'uz', 'Fayllar bilan ishlash: bilimni tekshirish',
    'Fayllar, xavfsiz oʻrnatish va zaxira nusxalar boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Working with files check', 'uz', '“Fayllar bilan ishlash” moduli boʻyicha test');
  perform seed.tr_question(c, 'Working with files check', 0, 'uz', '3-2-1 zaxiralash qoidasi nimani bildiradi?',
    'Uchta nusxa, ikki xil turdagi xotirada, bittasi boshqa joyda.',
    array['3 ta nusxa, 2 xil xotira, 1 nusxa boshqa joyda', 'Kuniga 3 ta zaxira, 2 ta parol, 1 ta bulut hisobi', '3 ta papka, 2 ta disk, 1 ta kompyuter']);
  perform seed.tr_question(c, 'Working with files check', 1, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: sinxronlangan bulut papkasining oʻzi toʻliq zaxira nusxa hisoblanadi.',
    'Notoʻgʻri. Sinxronlash oʻchirishlarni ham koʻchiradi; sizga versiyalar tarixi yoki alohida zaxira nusxa kerak.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array['Faylni oʻchirsangiz, sinxronlash uni hamma joydan oʻchiradi.', null]);
  perform seed.tr_question(c, 'Working with files check', 2, 'uz', 'Dasturni yuklab olish uchun eng xavfsiz joy qayer?',
    'Rasmiy ilovalar doʻkoni yoki ishlab chiqaruvchining oʻz sayti.',
    array['Rasmiy ilovalar doʻkoni yoki ishlab chiqaruvchining sayti', 'Qidiruv natijalaridagi birinchi reklama', '“Buzilgan” versiyani taklif qiladigan sayt'],
    array[null, 'Reklamalar koʻpincha oʻxshatib yasalgan saytlarga olib boradi.', 'Buzilgan dasturlar qonunga xilof va zararli dasturlarning keng tarqalgan manbai.']);
  perform seed.tr_question(c, 'Working with files check', 3, 'uz', 'Oʻrnatuvchi “bepul brauzer paneli”ni qoʻshishni taklif qilmoqda. Nima qilish kerak?',
    'Qoʻshimcha taklifdan belgini olib tashlang; faqat kerakli dasturni oʻrnating.',
    array['Taklifdan belgini olib tashlab, davom etish', 'Qabul qilish — axir u bepul', 'Bekor qilib, boshqa hech narsa oʻrnatmaslik'],
    array[null, 'Qoʻshib berilgan qoʻshimchalar koʻpincha keraksiz yoki zararli boʻladi.', 'Har bir oynani oʻqib, xavfsiz oʻrnatishingiz mumkin.']);
  perform seed.tr_question(c, 'Working with files check', 4, 'uz', 'Nega zaxira diskni doim ulangan holda qoldirmaslik kerak?',
    'Ransomware ulangan barcha disklardagi, jumladan, zaxira diskdagi fayllarni ham qulflashi mumkin.',
    array['Ransomware zaxira nusxani ham qulflashi mumkin', 'U kompyuterni sekinlashtiradi', 'Diskning quvvati tugab qoladi'],
    array[null, 'Ulangan disk kompyuterni sekinlashtirmaydi.', 'Tashqi disklarning quvvati tugaydigan oʻz batareyasi yoʻq.']);

  perform seed.tr_lesson(c, 'What an operating system does', 'uz', 'Operatsion tizim nima qiladi',
    'Foydalanuvchilar, ruxsatlar, yangilanishlar va kompyuter nima qilayotganini koʻrsatadigan vositalar.',
$md$## Kompyuterning boshqaruvchisi

Siz **operatsion tizim (OT)** qolgan barcha dasturlarni ishga tushiradigan asosiy dastur ekanini allaqachon bilasiz. Bu darsda u siz uchun nimalarni boshqarishini — va uning qaysi sozlamalari sizni xavfsiz saqlashini koʻrasiz.

Operatsion tizimning beshta asosiy vazifasi bor:

1. **Apparat** — u drayverlar orqali protsessor, xotira, doimiy xotira va qurilmalar bilan aloqa qiladi.
2. **Dasturlar** — ilovalarni ishga tushiradi, protsessor vaqtini ular oʻrtasida taqsimlaydi va ularni toʻxtatadi.
3. **Fayllar** — doimiy xotirani fayl va papkalarga ajratib tartibga soladi.
4. **Foydalanuvchilar va xavfsizlik** — har bir odamning fayllarini alohida saqlaydi va kim nima qila olishini hal qiladi.
5. **Interfeys** — sizga ish stoli, oynalar, menyular va sensorli imo-ishoralarni taqdim etadi.

Keng tarqalgan operatsion tizimlar: kompyuterlarda Windows, macOS va Linux, telefonlarda Android va iOS.

## Foydalanuvchilar va hisoblar

Kompyuterdan foydalanadigan har bir kishining oʻz fayllari va sozlamalari bilan alohida **foydalanuvchi hisobi** boʻlishi kerak.

- **Administrator** hisobi dasturlarni oʻrnatishi va tizim sozlamalarini oʻzgartirishi mumkin.
- **Standart** hisob ilovalardan foydalana oladi, ammo tizimdagi oʻzgarishlar uchun administrator ruxsati kerak.

> [!TIP]
> Kundalik ish uchun standart hisobdan foydalanish zararli faylni bilmasdan ochib qoʻysangiz, zararni cheklaydi: zararli dastur soʻramasdan tizimni oʻzgartira olmaydi.

## Ruxsatlar

Ilovalar kamera, mikrofon, joylashuv, kontaktlar yoki fayllaringiz kabi maxfiy narsalardan foydalanishdan oldin ruxsat soʻrashi shart. Faqat ilovaga haqiqatan kerak boʻlgan ruxsatni bering. Fonar ilovasining kontaktlaringizni oʻqishiga hech qanday sabab yoʻq.

- **Windows:** **Settings → Privacy & security**.
- **macOS:** **System Settings → Privacy & Security**.
- **Telefonlar:** **Settings → Apps** (Android) yoki **Settings → Privacy & Security** (iOS).

## Yangilanishlar

Operatsion tizim yangilanishlari jinoyatchilar faol foydalanadigan xavfsizlik teshiklarini yopadi. Ularni kechiktirmasdan oʻrnating va soʻralganda qayta ishga tushiring — koʻplab yangilanishlar faqat qayta ishga tushirilgandan keyin yakunlanadi.

## Nima ishlayotganini koʻrish

Ilova qotib qolganda operatsion tizim nima boʻlayotganini koʻrsata oladi:

- **Windows:** **Task Manager** (**Ctrl + Shift + Esc**) ishlab turgan ilovalarni va ularning har biri qancha protsessor va xotira ishlatayotganini koʻrsatadi. Qotib qolgan ilovani tanlab, **End task** ni bosing.
- **macOS:** **Activity Monitor** (**Applications → Utilities** ichida) xuddi shu ishni qiladi; **Force Quit** qotib qolgan ilovani toʻxtatadi (**Option + Command + Esc**).

## Oʻzingiz sinab koʻring

1. Operatsion tizimingizning qaysi versiyasi oʻrnatilganini toping.
2. Maxfiylik sozlamalarini ochib, qaysi ilovalar kamera va mikrofondan foydalana olishini tekshiring.
3. Task Manager yoki Activity Monitor ni ochib, eng koʻp xotira ishlatayotgan ilovani toping.

## Keng tarqalgan xatolar

- Yangilanishlarni haftalab kechiktirish.
- Hamma ish uchun administrator hisobidan foydalanish.
- Ilova soʻragan har bir ruxsatni oʻylamasdan berish.

## Asosiy atamalar

- **Operatsion tizim (OT)** — apparatni boshqaradigan va qolgan barcha dasturlarni ishga tushiradigan dastur.
- **Administrator / standart hisob** — tizimni oʻzgartira oladigan yoki oʻzgartira olmaydigan hisob.
- **Ruxsat** — ilovaning kamera kabi maxfiy narsadan foydalanish huquqi.
- **Task Manager / Activity Monitor** — ishlab turgan dasturlarni koʻrsatadigan vositalar.$md$);

  perform seed.tr_lesson(c, 'Passwords, two-factor authentication and phishing', 'uz', 'Parollar, ikki bosqichli autentifikatsiya va fishing',
    'Kuchli parollar, har bir muhim hisob uchun ikkinchi bosqich va firibgarlikni qanday aniqlash.',
$md$## Hisoblaringiz — sizning kalitlaringiz

Elektron pochta, messenjerlar, bank va oʻqish hisoblari hayotingizning katta qismini saqlaydi. Bu darsda hisoblar oʻgʻirlanishining aksariyatini toʻxtatadigan uchta odatni oʻrganasiz: kuchli va takrorlanmas parollar, ikki bosqichli autentifikatsiya hamda fishingni tanib olish.

## Kuchli parollar

- **Uzunlik murakkablikdan muhimroq.** `daryo-chiroq-apelsin-bulut` kabi toʻrt va undan ortiq tasodifiy soʻzdan iborat uzun parol iborasini topish `P@ss1` dan ancha qiyin.
- **Har bir hisob uchun alohida parol.** Bitta sayt buzilganda jinoyatchilar oʻsha email va parolni boshqa barcha joylarda sinab koʻradi.
- **Parollar menejeridan foydalaning.** U kuchli va takrorlanmas parollarni yaratadi va eslab qoladi, shuning uchun siz faqat bitta asosiy parolni eslab qolishingiz kifoya. Mashhur menejerlar brauzer va telefonlarga oʻrnatilgan, alohida ilovalar ham bor.

> [!WARNING]
> Parolda hech qachon shaxsiy maʼlumotlardan — ismingiz, tugʻilgan kuningiz yoki telefon raqamingizdan foydalanmang. Hujumchilar birinchi navbatda aynan shularni sinab koʻradi.

## Ikki bosqichli autentifikatsiya (2FA)

2FA — tizimga kirish uchun **ikki xil dalil** kerak degani: siz **biladigan** narsa (parolingiz) va sizda **bor** narsa (telefoningiz yoki xavfsizlik kaliti).

- **Autentifikator ilovasi** har 30 soniyada yangi olti xonali kod koʻrsatadi — tavsiya etiladigan usul.
- **SMS kod** kuchsizroq, chunki telefon raqamini egallab olish mumkin, ammo u baribir ikkinchi bosqichning umuman yoʻqligidan ancha yaxshi.
- **Passkey** (kirish kaliti) parol oʻrniga barmoq izi yoki yuz bilan kirish imkonini beradi va uni fishing orqali oʻgʻirlab boʻlmaydi.

2FA ni birinchi navbatda elektron pochtangiz uchun yoqing — u orqali boshqa barcha parollarni tiklash mumkin.

## Fishing

**Fishing** — parol yoki kodni berib qoʻyishingiz uchun siz ishonadigan kimsa — bank, yetkazib berish xizmati yoki messenjerning qoʻllab-quvvatlash xizmati nomidan yuborilgan soxta xabar.

Ogohlantiruvchi belgilar:

- **Shoshiltirish yoki tahdid:** “Kartangiz bir soatdan keyin bloklanadi.”
- **Mos kelmaydigan havola:** matnda bankingiz nomi yozilgan, lekin manzil `bank-secure-login.example` ga oʻxshash.
- **Bir martalik kodni soʻrash.** Hech bir haqiqiy bank yoki messenjer sizdan SMS orqali kelgan kodni aytishingizni soʻramaydi.

> [!TIP]
> Biror xabar sizni xavotirga solsa, undagi havola yoki telefon raqamlaridan foydalanmang. Rasmiy ilovani oching yoki bank kartangizda yozilgan raqamga qoʻngʻiroq qiling.

## Agar fishing havolasini bosib qoʻygan boʻlsangiz

1. Oʻsha hisob parolini (va u takrorlangan barcha joylarda) darhol oʻzgartiring.
2. Agar 2FA oʻchiq boʻlsa, uni yoqing.
3. Hisobdagi faol seanslar yoki qurilmalar roʻyxatini tekshiring va tanimaganlaringizdan chiqib keting.
4. Agar pul yoki bank kartasi bilan bogʻliq boʻlsa, darhol bankingizga qoʻngʻiroq qiling.

## Oʻzingiz sinab koʻring

Asosiy elektron pochta hisobingiz uchun autentifikator ilovasi orqali ikki bosqichli autentifikatsiyani yoqing. Soʻngra biror kompaniyadan kelgan soʻnggi xabarni ochib, undagi havolalarning haqiqiy manzilini tekshiring.

## Keng tarqalgan xatolar

- Bitta parolni bir nechta saytda ishlatish.
- “Bankda ishlayman” degan kishiga telefonda bir martalik kodni aytib berish.
- Xabarda tanish logotip borligi uchun unga ishonish.

## Asosiy atamalar

- **Parol iborasi** (*passphrase*) — bir nechta soʻzdan iborat uzun parol.
- **Parollar menejeri** — takrorlanmas parollarni yaratadigan va saqlaydigan ilova.
- **Ikki bosqichli autentifikatsiya (2FA)** — shaxsni ikki xil dalil bilan tasdiqlab kirish.
- **Fishing** — parol, kod yoki pulni oʻgʻirlash uchun yuborilgan soxta xabar.$md$);

  perform seed.tr_lesson(c, 'Staying safe: check', 'uz', 'Xavfsizlik: bilimni tekshirish',
    'Hisoblar, ruxsatlar, parollar va fishing boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Staying safe check', 'uz', '“Xavfsizlik va nazorat” moduli boʻyicha test');
  perform seed.tr_question(c, 'Staying safe check', 0, 'uz', 'Qaysi parol eng kuchli?',
    'Eng muhimi — uzunlik: bir nechta tasodifiy soʻzdan iborat parol iborasi qisqa, murakkab paroldan kuchliroq.',
    array['`daryo-chiroq-apelsin-bulut`', '`P@ss1`', '`Aziza2008`'],
    array[null, 'Qisqa parollar belgilar boʻlsa ham tez topiladi.', 'Ism va yillar hujumchilar birinchi sinab koʻradigan narsa.']);
  perform seed.tr_question(c, 'Staying safe check', 1, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: bankda ishlashini aytgan va ismingizni biladigan qoʻngʻiroq qiluvchiga SMS kodni aytish xavfsiz.',
    'Notoʻgʻri. Banklar hech qachon bir martalik kodlarni soʻramaydi. Goʻshakni qoʻying va kartangizdagi raqamga qoʻngʻiroq qiling.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array['Ismingizni bilishi hech narsani isbotlamaydi; bu klassik firibgarlik.', null]);
  perform seed.tr_question(c, 'Staying safe check', 2, 'uz', 'Nega kundalik ish uchun standart (administrator boʻlmagan) hisobdan foydalanish kerak?',
    'Zararli dasturlar va xatolar administrator ruxsatisiz tizimni oʻzgartira olmaydi.',
    array['U zararli dasturlar va xatolardan keladigan zararni cheklaydi', 'U internetni tezlashtiradi', 'U batareyani tejaydi']);
  perform seed.tr_question(c, 'Staying safe check', 3, 'uz', 'Fonar ilovasi kontaktlaringizdan foydalanishga ruxsat soʻramoqda. Nima qilasiz?',
    'Ilovaga faqat kerakli ruxsatni bering; fonarga kontaktlaringiz kerak emas.',
    array['Rad etaman', 'Ruxsat beraman — ilovalarga hammasi kerak', 'Nima boʻlishini koʻrish uchun bir marta ruxsat beraman'],
    array[null, 'Ilovalar faqat kerakli ruxsatlarni olishi kerak.', 'Ruxsat berilgach, ilova kontaktlaringizdan nusxa olishi mumkin.']);
  perform seed.tr_question(c, 'Staying safe check', 4, 'uz', 'Quyidagilardan qaysilari fishingning ogohlantiruvchi belgilari? Mos keladigan **barcha** variantlarni belgilang.',
    'Shoshiltirish, mos kelmaydigan havolalar va kod soʻrash — klassik belgilar.',
    array['“Kartangiz bloklanadi” kabi shoshilinch tahdid', 'Manzili kompaniyaga mos kelmaydigan havola', 'Bir martalik kodni soʻrash', 'Tanish kontaktdan kutilgan, oddiy mazmundagi xabar'],
    array[null, null, null, 'Kutilgan, oddiy xabarlarning oʻzi ogohlantiruvchi belgi emas.']);

  perform seed.tr_lesson(c, 'Project: set up and secure a computer', 'uz', 'Loyiha: kompyuterni sozlash va himoyalash',
    'Real inson uchun kompyuter tanlang, sozlang va himoyalang hamda tanlovlaringizni tushuntiring.',
$md$## Loyihangiz

Qarindoshingiz yoki doʻstingizga oʻqish yoki ish uchun kompyuter kerak. IT mutaxassisi kabi, kompyuterni tanlash, sozlash va himoyalashni qamrab oladigan qisqa reja tayyorlang.

### Nimani topshirish kerak

1. **Kim uchun** — inson, u kompyuterdan nima uchun foydalanishi va byudjet.
2. **Texnik tavsif** — protsessor, RAM, doimiy xotira va portlar; har bir tanlov bir gap bilan izohlangan.
3. **Sozlash rejasi** — foydalanuvchi hisoblari (administrator va standart), yangilanishlar va rasmiy manbalardan oʻrnatiladigan dasturlar.
4. **Zaxiralash rejasi** — qaysi fayllar muhim va 3-2-1 qoidasiga qanday amal qilinadi.
5. **Xavfsizlik rejasi** — parollar menejeri, asosiy hisoblar uchun ikki bosqichli autentifikatsiya va unga oʻrgatadigan fishingning uchta belgisi.

### Qanday topshiriladi

Rejangizni matn maydoniga yozing (taxminan bir sahifa), hujjat sifatida yuklang yoki unga havola ulashing.

> [!NOTE]
> Tekshiruvchi rejangizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Uni yaxshilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Set up and secure a computer'), 'uz',
    jsonb_build_object(
      'title', 'Kompyuterni sozlash va himoyalash',
      'brief_md', 'Real inson uchun kompyuterni tanlash, sozlash, zaxiralash va himoyalash boʻyicha bir sahifalik reja yozing.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Texnik tavsif insonga va byudjetga mos, har bir qism izohlangan | 25 |
| Sozlash rejasi: hisoblar, yangilanishlar va rasmiy manbalardan dasturlar | 20 |
| 3-2-1 qoidasiga mos zaxiralash rejasi | 25 |
| Xavfsizlik rejasi: parollar, 2FA va fishingdan xabardorlik | 20 |
| Aniq va tartibli yozilgan matn | 10 |$r$),
    c || ' / Set up and secure a computer');

  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 4, 'uz', 'RAM nima uchun ishlatiladi?',
    'RAM — ayni paytda ochiq turgan narsalar uchun tezkor, vaqtinchalik ishchi xotira.',
    array['Ochiq ilova va fayllar uchun vaqtinchalik ishchi maydon', 'Kompyuter oʻchiq boʻlganda fayllarni saqlash', 'Wi-Fi ga ulanish'],
    array[null, 'Bu doimiy xotira (SSD yoki HDD) vazifasi.', 'Wi-Fi bilan tarmoq adapteri ishlaydi.']);
  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 5, 'uz', 'Dastur oʻrnatishda qaysi odat eng xavfsiz?',
    'Rasmiy doʻkonlar yoki ishlab chiqaruvchi saytidan foydalaning va oʻrnatuvchining har bir oynasini oʻqing.',
    array['Rasmiy manbalardan yuklab olish va oʻrnatuvchining har bir oynasini oʻqish', 'Koʻringan birinchi yuklab olish tugmasini bosish', 'Pullik ilovalarning buzilgan versiyalarini oʻrnatish']);
  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 6, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: 3-2-1 qoidasiga koʻra maʼlumotlaringizning bitta nusxasi boshqa joyda saqlanishi kerak.',
    'Toʻgʻri — boshqa joydagi nusxa (masalan, bulutda) uydagi yongʻin, suv toshqini yoki oʻgʻirlikdan omon qoladi.',
    array['Toʻgʻri', 'Notoʻgʻri']);
  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 7, 'uz', 'Ikki bosqichli autentifikatsiya nima?',
    'Parol va telefoningizdagi kod kabi ikki xil dalil bilan tizimga kirish.',
    array['Parol va telefon kodi kabi ikkinchi dalil bilan tizimga kirish', 'Ikki xil paroldan foydalanish', 'Ikki qurilmada tizimga kirish']);
  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 8, 'uz', 'Sizga xabar keldi: “Kartangiz bloklandi — ochish uchun bizga SMS kodni yuboring.” Nima qilasiz?',
    'Bir martalik kodlarni hech qachon bermang. Bank bilan uning rasmiy ilovasi yoki kartangizdagi raqam orqali bogʻlaning.',
    array['Xabarga eʼtibor bermay, bank bilan rasmiy kanallar orqali bogʻlanaman', 'Karta bloklanmasidan oldin kodni tezda yuboraman', 'Bu haqiqiymi, deb javob yozaman'],
    array[null, 'Kodni berish firibgarga hisobingizga kirish imkonini beradi.', 'Javob yozish raqamingiz faol ekanini tasdiqlaydi; buning oʻrniga rasmiy kanallardan foydalaning.']);
  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 9, 'uz', 'Quyidagilardan qaysilari operatsion tizimning vazifasi? Mos keladigan **barcha** variantlarni belgilang.',
    'Operatsion tizim apparatni boshqaradi, dasturlarni ishga tushiradi, fayllarni tartibga soladi hamda foydalanuvchilar va ruxsatlarni nazorat qiladi.',
    array['Apparatni boshqarish', 'Dasturlarni ishga tushirish va toʻxtatish', 'Foydalanuvchi hisoblari va ruxsatlarni nazorat qilish', 'Veb-saytlarni loyihalash'],
    array[null, null, null, 'Veb-saytlarni odamlar ilovalar yordamida loyihalaydi.']);
end $tr$;
