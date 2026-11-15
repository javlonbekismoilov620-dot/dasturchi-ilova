# Sprint 1: complete the eight published courses

**Rule:** no new courses until Sprint 1 is complete and verified (decision of 15 November 2026).

**Scope:**
- 44 written lessons, including projects, in English and Oʻzbekcha.
- 20 knowledge checks and final assessments, also in English and Oʻzbekcha.

Existing lessons keep their IDs. Unpublished placeholder rows are completed in place, and nothing is deleted. A course becomes *complete* only when the audit's readiness checklist passes **and** the expert and native-Uzbek reviews are approved in Studio.

## Result: written, in the app and verified (15 November 2026)

All lessons below are written in English and Oʻzbekcha and published. **No course is marked complete yet**: each one still needs the expert review and the native-Uzbek review in Studio, so the app keeps labelling them *In development*.

| Course | Lessons before → now | Quizzes · questions | Projects | Status |
| --- | --- | --- | --- | --- |
| Computer Fundamentals from Zero | 5 → 15 | 5 · 30 | 1 | ✅ written, verified · reviews pending |
| HTML from Absolute Zero | 6 → 17 | 6 · 30 | 2 | ✅ written, verified · reviews pending |
| Python for Complete Beginners | 3 → 18 | 5 · 26 | 2 | ✅ written, verified · reviews pending |
| Blender: Your First Steps in 3D | 6 → 13 | 4 · 22 | 1 | ✅ written, verified · reviews pending |
| Video Editing Fundamentals | 3 → 10 | 3 · 16 | 1 | ✅ written, verified · reviews pending |
| Design Principles from Zero | 3 → 10 | 3 · 16 | 1 | ✅ written, verified · reviews pending |
| AI Fundamentals & Prompting | 3 → 10 | 3 · 16 | 1 | ✅ written, verified · reviews pending |
| Unreal Engine Fundamentals | 1 → 6 | 2 · 13 | 1 | ✅ written, verified · reviews pending |
| **Total** | **30 → 99** | **31 · 169** | **10** | |

The tables below list what was added to each course.

## Unreal Engine Fundamentals: 6 lessons (scope per decision 1)

| Module | Lesson | Type | Status |
| --- | --- | --- | --- |
| Getting started | What is a game engine? | article | ✅ existing |
| | Installing Unreal Engine | article | ✅ completed in place |
| | A tour of the editor | article | ✅ completed in place |
| | Check your understanding | knowledge check | ✅ |
| Project and final assessment | Project: your first scene | project | ✅ |
| | Final assessment | final assessment | ✅ |

The rest of the Unreal curriculum is planned but not in Sprint 1: Building a scene, Look and feel, and Making it playable ([unreal-engine.md](unreal-engine.md)). It will follow once the course passes review.

## Computer Fundamentals from Zero: 5 → 15

| Module | New lessons |
| --- | --- |
| Inside the machine *(new)* | Processor and memory: how a computer thinks · Ports, peripherals and reading a spec sheet · Inside the machine: check |
| Working with files | Installing and removing software safely *(existing row)* · Backups and the cloud *(existing row)* · Working with files: check |
| Staying safe and in control *(new)* | What an operating system does · Passwords, two-factor authentication and phishing · Staying safe: check |
| Final assessment | Project: set up and secure a computer · final assessment extended to the new modules |

## HTML from Absolute Zero: 6 → 17

| Module | New lessons |
| --- | --- |
| Structuring content | Tables for real data · Structuring content: check |
| Links, images and media *(existing draft module)* | Links: connecting the web *(existing row)* · Images done right *(existing row)* · Links and images: check |
| Forms and accessibility *(new)* | Forms: collecting input · Semantic layout and accessibility · Forms and accessibility: check |
| Publish your site *(new)* | Publishing with GitHub Pages · Final project: your portfolio site · Final assessment |

## Python for Complete Beginners: 3 → 18

| Module | New lessons |
| --- | --- |
| Thinking like a programmer | Input and output |
| Making decisions *(existing draft module)* | Comparing values *(existing row)* · if, elif and else *(existing row)* · Making decisions: check |
| Repetition *(new)* | while loops · for loops and range() · Repetition: check |
| Collections and functions *(new)* | Lists · Dictionaries · Functions · Collections and functions: check |
| Files, errors and projects *(new)* | Files and errors · Project: quiz game · Project: budget tracker · Final assessment |

## Blender: Your First Steps in 3D: 6 → 13

| Module | New lessons |
| --- | --- |
| Understanding 3D | Understanding 3D: check |
| Moving around and basic objects | Object mode, Edit mode and the origin |
| Your first render *(existing draft module)* | Giving objects a material *(existing row)* · Lighting and rendering your first image *(existing row)* · First render: check |
| Final project and assessment *(new)* | Project: a still-life scene · Final assessment |

## Video Editing Fundamentals: 3 → 10

| Module | New lessons |
| --- | --- |
| Pictures and sound *(new)* | Shots, composition and continuity · Sound for editors · Pictures and sound: check |
| Your first edit *(new)* | Your first edit · Exporting your video · Project: a day-in-the-life edit · Final assessment |

## Design Principles from Zero: 3 → 10

| Module | New lessons |
| --- | --- |
| Colour and type *(new)* | Colour basics · Type basics · Colour and type: check |
| Layout and critique *(new)* | Grids and layout · Giving and receiving critique · Project: an event poster · Final assessment |

## AI Fundamentals & Prompting: 3 → 10

| Module | New lessons |
| --- | --- |
| Using AI well *(new)* | Limits: hallucination, outdated knowledge and bias · Checking AI answers · Privacy and safety with AI · Using AI well: check |
| AI in everyday life *(new)* | Studying and working with AI · Project: a verified explainer · Final assessment |

## Verification for each course

1. The content audit passes: Uzbek complete, orthography, structure parity, quiz integrity.
2. The readiness checklist shows only the two human reviews outstanding.
3. The progress fingerprint is unchanged on a database with existing learners.
4. The demo catalog is regenerated, the language journey passes, and the iPhone preview is republished.
5. Then the expert and native-Uzbek reviews happen in Studio. Only after both are approved can the course be marked complete.

### Verification results (15 November 2026)

| Step | Result |
| --- | --- |
| 1. Content audit | 7/7 checks pass on a fresh `supabase db reset` |
| 2. Readiness checklist | All eight courses: structure, knowledge checks, project and final assessment ✅; only the expert and native-Uzbek reviews are outstanding |
| 3. Progress fingerprint | Identical before and after loading all Sprint 1 content onto a database with existing learners; none of the 40 earlier lesson IDs changed |
| Completion, server | New E2E test completes every course as a learner. No course completes before its final assessment, wrong answers fail it, every lesson ends up completed, and a certificate is issued |
| Completion, demo engine (iPhone preview) | Same journey for all eight courses; every lesson opens and shows Uzbek |
| 4. Demo catalog, language journey, iPhone preview | Catalog regenerated with stable IDs (progress saved on a device is kept), language journey 24/24, iPhone preview republished |
