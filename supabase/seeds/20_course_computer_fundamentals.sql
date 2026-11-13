-- Course: Computer Fundamentals from Zero (free, level: zero)
do $seed$
declare
  c uuid; m1 uuid; m2 uuid; m3 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('computer-fundamentals-from-zero', 'Computer Fundamentals from Zero',
    'Understand the machine in front of you — no prior knowledge needed',
    $d$This course assumes **nothing**. If you have ever wondered what actually happens inside a computer, why files have strange endings like `.pdf`, or what people mean by “hardware” and “software”, you are in the right place.

You will build a clear mental model of how a computer takes in information, works on it, stores it and shows you the result. Every term is explained the first time it appears.$d$,
    seed.cat('information-technology'), seed.cat('computer-fundamentals'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'free', 'published', 60,
    array['Explain what a computer is using the input → processing → storage → output model',
          'Tell hardware and software apart and name the main parts of a computer',
          'Understand bits and bytes and read storage sizes like GB and TB',
          'Navigate files, folders and paths with confidence'],
    array['No prior knowledge — just curiosity and access to any computer'],
    array['computers', 'basics', 'hardware', 'software', 'files'], true,
    '{"pattern": "grid", "hue": 205}')
  returning id into c;

  m1 := seed.module(c, 0, 'What a computer really is', 'The core idea behind every computer, from phones to servers.');

  l := seed.lesson(m1, 0, 'What is a computer?', 'article', 6,
    'A computer is a machine that follows instructions to turn input into useful output.',
$md$## A machine that follows instructions

A **computer** is a machine that takes in information, follows a list of instructions to work with that information, and gives you a result. That’s it. Your laptop, your phone, a smartwatch, a cash register and the servers that run websites are all computers.

What makes computers special is not that they are clever — they are not. They are **extremely fast** and **perfectly obedient**. A modern computer can follow billions of simple instructions every second, exactly as written.

> [!NOTE]
> The list of instructions a computer follows is called a **program**. Writing programs is called **programming**.

## The four jobs of every computer

Every computer, no matter its size, does the same four jobs:

1. **Input** — receiving information. Typing on a keyboard, tapping a screen, speaking into a microphone or taking a photo are all input.
2. **Processing** — working on that information by following instructions. Adding numbers, applying a photo filter or checking a password are processing.
3. **Storage** — keeping information so it can be used later. Your photos, documents and installed apps are stored.
4. **Output** — showing or sending the result. Text on a screen, sound from a speaker, a printed page or a message sent to a friend are output.

## An everyday example

When you take a photo with your phone:

- the camera captures light — **input**
- the phone improves colours and sharpness — **processing**
- the photo is saved to the gallery — **storage**
- the photo appears on your screen — **output**

> [!TIP]
> Whenever a new technology feels confusing, ask: *what is the input, what processing happens, what is stored, and what is the output?* This one question explains a surprising amount of computing.

## Key terms

- **Computer** — a machine that follows instructions to process information.
- **Program** — a list of instructions for a computer.
- **Input / Output** — information going into / coming out of a computer.$md$,
    'published', false, 10);

  l := seed.lesson(m1, 1, 'Hardware and software', 'article', 8,
    'The physical parts you can touch, and the instructions that bring them to life.',
$md$## Two halves of every computer

Every computer is made of two kinds of things:

- **Hardware** — the physical parts you could touch: the screen, keyboard, chips and cables.
- **Software** — the instructions (programs) that tell the hardware what to do: the operating system, a web browser, a game.

Hardware without software is a box that does nothing. Software without hardware has nowhere to run. You need both.

## The main hardware parts

| Part | What it does | A simple comparison |
| --- | --- | --- |
| **CPU** (processor) | Follows instructions — the “thinking” part | A chef following a recipe |
| **RAM** (memory) | Holds what you are working on *right now* | The chef’s worktable |
| **Storage** (SSD or hard drive) | Keeps files and apps even when power is off | The pantry |
| **GPU** (graphics processor) | Draws images, video and 3D quickly | A specialist pastry chef |
| **Motherboard** | Connects every part so they can communicate | The kitchen itself |
| **Power supply / battery** | Provides electricity | The gas line |

> [!NOTE]
> **RAM is temporary.** When the power goes off, whatever is only in RAM disappears. That is why you *save* your work — saving copies it from RAM to storage.

## Kinds of software

- **Operating system (OS)** — the main program that manages the hardware and runs everything else. Examples: Windows, macOS, Linux, Android, iOS.
- **Applications (apps)** — programs that help you do a task: a browser, a photo editor, a messenger.
- **Drivers** — small programs that let the operating system talk to a specific piece of hardware, such as a printer.

## Bits and bytes

Inside the computer, all information — text, photos, music — is stored as numbers made of only two digits, **0** and **1**. One such digit is a **bit**.

- 8 bits = 1 **byte** (enough to store one simple letter like “A”)
- about 1,000 bytes = 1 **kilobyte (KB)**
- about 1,000 KB = 1 **megabyte (MB)** — a typical photo is a few MB
- about 1,000 MB = 1 **gigabyte (GB)** — a film is a few GB
- about 1,000 GB = 1 **terabyte (TB)**

> [!TIP]
> When buying a computer, *storage* (e.g. 512 GB SSD) tells you how much you can keep, while *RAM* (e.g. 16 GB) tells you how much you can work on at the same time.$md$,
    'published', false, 10);

  l := seed.lesson(m1, 2, 'Check your understanding', 'quiz', 4,
    'Five quick questions on computers, hardware and software.', null, 'published', false, 15);
  q := seed.quiz(c, m1, l, 'Module 1 check', 'knowledge_check', 60, 20);

  qq := seed.question(q, 0, 'single_choice', 'You type a message and press **Send**. Which of the four jobs is *typing* the message?',
    'Typing gives information **to** the computer, so it is input.');
  perform seed.answer(qq, 0, 'Input', true, 'Correct — you are giving information to the computer.');
  perform seed.answer(qq, 1, 'Processing', false, 'Processing is the computer working on information, not you entering it.');
  perform seed.answer(qq, 2, 'Storage', false, 'Storage is keeping information for later.');
  perform seed.answer(qq, 3, 'Output', false, 'Output is information coming *out* of the computer.');

  qq := seed.question(q, 1, 'single_choice', 'Which part temporarily holds what you are working on right now, and is cleared when the power goes off?',
    'RAM is fast, temporary working memory. Storage keeps files permanently.');
  perform seed.answer(qq, 0, 'Storage (SSD)', false, 'An SSD keeps data even without power.');
  perform seed.answer(qq, 1, 'RAM', true, 'Yes — that is why unsaved work can be lost.');
  perform seed.answer(qq, 2, 'GPU', false, 'The GPU draws graphics; it is not general working memory.');
  perform seed.answer(qq, 3, 'Power supply', false, 'The power supply provides electricity, not memory.');

  qq := seed.question(q, 2, 'multiple_choice', 'Select **all** the items that are software.',
    'Software is instructions. Windows and a web browser are programs; a keyboard and a monitor are physical hardware.');
  perform seed.answer(qq, 0, 'Windows', true);
  perform seed.answer(qq, 1, 'A web browser', true);
  perform seed.answer(qq, 2, 'A keyboard', false, 'A keyboard is a physical input device — hardware.');
  perform seed.answer(qq, 3, 'A monitor', false, 'A monitor is a physical output device — hardware.');

  qq := seed.question(q, 3, 'true_false', 'True or false: 1 byte is made of 8 bits.',
    'A byte is a group of 8 bits.');
  perform seed.answer(qq, 0, 'True', true);
  perform seed.answer(qq, 1, 'False', false, 'It is true — 8 bits make one byte.');

  qq := seed.question(q, 4, 'single_choice', 'Which is the largest amount?',
    'KB < MB < GB < TB. Each step is roughly 1,000 times bigger.');
  perform seed.answer(qq, 0, '500 MB', false);
  perform seed.answer(qq, 1, '2 GB', false);
  perform seed.answer(qq, 2, '1 TB', true, 'Right — a terabyte is about 1,000 gigabytes.');
  perform seed.answer(qq, 3, '900 KB', false);

  m2 := seed.module(c, 1, 'Working with files', 'How information is organised so you can always find it again.');

  l := seed.lesson(m2, 0, 'Files, folders and paths', 'article', 8,
    'Name things well, organise them in folders, and read a path like a street address.',
$md$## What is a file?

A **file** is a single piece of stored information with a name: a document, a photo, a song, a program. Files live on storage (your SSD or hard drive, a USB stick, or the cloud).

Most file names end with a dot and a few letters, for example `report.pdf` or `holiday.jpg`. That ending is the **file extension**. It tells the computer what kind of file it is and which app should open it.

| Extension | Kind of file |
| --- | --- |
| `.pdf` | Document that looks the same everywhere |
| `.docx` | Word document |
| `.jpg`, `.png` | Image |
| `.mp4` | Video |
| `.mp3` | Audio |
| `.zip` | Several files compressed into one |

> [!WARNING]
> Renaming `photo.jpg` to `photo.mp4` does **not** turn a photo into a video. It only confuses the computer about which app to use.

## Folders

A **folder** (also called a *directory*) is a container for files and other folders. Folders inside folders create a tree:

```text
Documents
├── School
│   ├── math-homework.pdf
│   └── essay.docx
└── Work
    └── invoice-march.pdf
```

## Paths: a file’s address

A **path** is the full address of a file — every folder you pass through to reach it.

- On **Windows**: `C:\Users\Aziza\Documents\School\essay.docx`
- On **macOS** and **Linux**: `/Users/aziza/Documents/School/essay.docx`

Read it left to right like an address: drive or root → user → folder → sub-folder → file. Windows uses a backslash `\` between folders; macOS and Linux use a forward slash `/`.

> [!TIP]
> Good habits that professionals use:
> - Use clear names: `invoice-2026-03.pdf` beats `scan1 final FINAL.pdf`.
> - Put dates as `YYYY-MM-DD` so files sort in order.
> - Avoid spaces and special symbols in names for files you will use in code or on the web.
> - Keep a backup of important files in a second place.$md$,
    'published', false, 10);

  -- Planned lessons still in production (hidden from learners until published)
  perform seed.lesson(m2, 1, 'Installing and removing software safely', 'article', 8,
    'Where to download apps, how installers work and how to uninstall cleanly.', null, 'draft');
  perform seed.lesson(m2, 2, 'Backups and the cloud', 'article', 8,
    'The 3-2-1 backup rule and how cloud storage works.', null, 'draft');

  m3 := seed.module(c, 2, 'Final assessment', 'Show what you have learned to earn your certificate.');
  l := seed.lesson(m3, 0, 'Final assessment', 'quiz', 6,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.quiz(c, m3, l, 'Computer Fundamentals — final assessment', 'final_assessment', 70, 50);

  qq := seed.question(q, 0, 'single_choice', 'Which piece of software manages the hardware and runs all other programs?',
    'The operating system (Windows, macOS, Linux, Android, iOS) sits between hardware and apps.');
  perform seed.answer(qq, 0, 'A web browser', false, 'A browser is an application that runs *on* the operating system.');
  perform seed.answer(qq, 1, 'The operating system', true);
  perform seed.answer(qq, 2, 'A driver', false, 'A driver helps the OS talk to one device; it does not run everything.');

  qq := seed.question(q, 1, 'short_answer', 'What is the extension of the file `summer-trip.mp4`? (type just the letters, without the dot)',
    'The extension is the part after the last dot: **mp4**, which marks a video file.');
  perform seed.answer(qq, 0, 'mp4', true);
  perform seed.answer(qq, 1, '.mp4', true);

  qq := seed.question(q, 2, 'single_choice', 'In the path `/Users/aziza/Documents/School/essay.docx`, which folder directly contains the file?',
    'Read the path left to right — the last folder before the file name contains it.');
  perform seed.answer(qq, 0, 'Users', false);
  perform seed.answer(qq, 1, 'Documents', false, 'Documents contains the School folder, which contains the file.');
  perform seed.answer(qq, 2, 'School', true);

  qq := seed.question(q, 3, 'multiple_choice', 'Which of these are examples of **output**?',
    'Output is information coming out of the computer — through the screen, speakers or a printer.');
  perform seed.answer(qq, 0, 'Music playing from speakers', true);
  perform seed.answer(qq, 1, 'A page coming out of a printer', true);
  perform seed.answer(qq, 2, 'Speaking into a microphone', false, 'That is input.');
  perform seed.answer(qq, 3, 'Scanning a document', false, 'A scanner sends information into the computer — input.');
end $seed$;
