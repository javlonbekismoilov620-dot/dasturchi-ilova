# Mahorat curriculum — from absolute zero to professional

This folder holds the curriculum for the seven subjects. **It is a plan for content production, not content.** No course is added to the app until its lessons are written, reviewed and translated. The goal is a smaller library of deep, practical courses, not a large catalog of placeholders.

| Subject | File | Existing entry course |
| --- | --- | --- |
| Information Technology | [information-technology.md](information-technology.md) | Computer Fundamentals from Zero |
| Programming | [programming.md](programming.md) | HTML from Absolute Zero · Python for Complete Beginners |
| Blender & 3D | [blender.md](blender.md) | Blender: Your First Steps in 3D |
| Unreal Engine & games | [unreal-engine.md](unreal-engine.md) | Unreal Engine Fundamentals |
| Video editing | [video-editing.md](video-editing.md) | Video Editing Fundamentals |
| Graphic design | [graphic-design.md](graphic-design.md) | Design Principles from Zero |
| Artificial intelligence | [artificial-intelligence.md](artificial-intelligence.md) | AI Fundamentals & Prompting |

## Levels

These are the levels the app already uses (`difficulty_level`). Each level has an exit standard, which is what a learner can *do* when they finish it.

| Level | Learner starts with | Exit standard |
| --- | --- | --- |
| **Zero** | No knowledge, no tools installed | Explains the core ideas in their own words and has completed one small guided task |
| **Beginner** | Zero-level ideas | Completes standard tasks with the main tool by following a brief, with help |
| **Intermediate** | Beginner skills | Builds a complete small project independently and can explain design choices |
| **Advanced** | Several projects | Solves open-ended problems, debugs, optimises, and uses professional workflows |
| **Professional** | Advanced skills | Delivers client- or team-grade work end to end: briefs, estimates, review, delivery and maintenance |
| **Expert** | Professional practice | Specialises: leads, mentors, designs systems and processes. Taught through capstones and specialisations, not long lecture courses |

A course can span two adjacent levels, for example Zero → Beginner.

## Standard for every lesson

A lesson is ready for review when it has all of the following:

1. **One clear objective**, phrased as an action: “By the end you can …”.
2. **The why before the how.** A concept explanation in plain language. Every new term is defined the first time it appears.
3. **A worked example** the learner can reproduce: code, a file, a scene, footage or a layout.
4. **Try it:** a short practice task with an expected result, so learners can check themselves.
5. **Common mistakes** and how to recognise and fix them.
6. **Key terms** at the end. The English term is given alongside the Uzbek or Russian on first use.
7. **Length:** 800–1,500 words of reading, or 6–12 minutes of video with a transcript and a written summary. Split anything longer.
8. **Media** shows the current version of the tool, with the version stated in the lesson.

Each **module** ends with a knowledge check of 4–8 questions. Every question needs an explanation, and feedback for each wrong option. Every module also has a practical exercise. Each **course** ends with a project (with a published rubric) and a final assessment. Pass marks are 70% for knowledge checks and final assessments.

## Definition of done for a course

`content_complete` may be set only when **all** of these are true. The content audit in `npm run db:test` enforces the measurable parts.

- [ ] Every planned lesson is published; there are no draft gaps in the middle of a module.
- [ ] Every module has a knowledge check and a practical exercise.
- [ ] The course has a final project with a rubric, and a final assessment.
- [ ] A subject-matter expert has reviewed it. The reviewer and date are recorded in Studio's audit log.
- [ ] Uzbek and Russian translations pass the content audit, and a native speaker has reviewed them.
- [ ] Tool-based courses have video or step-by-step screenshots for every hands-on lesson.
- [ ] Downloadable starter and finished project files are attached where the course uses them.

## Production order

The first priority is to **finish what learners can already see**, before opening new courses.

**Sprint 1: complete the eight published entry courses**: 44 written lessons (including projects) plus 20 knowledge checks and assessments, listed exactly in [sprint-1.md](sprint-1.md). The per-course totals below were rough estimates; sprint-1.md is the authoritative list.

| Course | Now | Target | Main additions |
| --- | --- | --- | --- |
| Computer Fundamentals from Zero | 5 lessons | 14 | Hardware in depth, OS basics, safe installs, backups, internet safety, project |
| HTML from Absolute Zero | 6 | 14 | Links, images, forms, semantic layout, accessibility, publishing |
| Python for Complete Beginners | 3 | 16 | Input/output, conditions, loops, functions, lists, dictionaries, files, errors, two projects |
| Blender: Your First Steps in 3D | 6 | 10 | Materials, lighting, first render, saving, project |
| Video Editing Fundamentals | 3 | 10 | Shots and composition, audio basics, hands-on edit, export, project |
| Design Principles from Zero | 3 | 10 | Colour, typography, grids, critique, poster project |
| AI Fundamentals & Prompting | 3 | 9 | Limitations, privacy and safety, verification, everyday uses, project |
| Unreal Engine Fundamentals | 1 | 10 | Installation, editor tour, actors, materials, lighting, packaging, quiz, project |

**Sprint 2: the next course in every track,** so that each subject has a Beginner step:
- CSS from Zero
- JavaScript from Zero
- Operating Systems in Practice
- Blender Modeling Foundations
- DaVinci Resolve Essentials
- Colour & Typography
- Practical AI for Work & Study

**After that,** follow learner demand. Studio's dashboard shows enrolments and completion rates per course, and the curriculum files list the order inside each track.

## Effort estimates

These figures cover writing and review per finished lesson. Translation into two languages adds about 40%.

| Lesson type | Writing | Expert review | Media |
| --- | --- | --- | --- |
| Concept article | 3–4 h | 1 h | Diagrams: 1–2 h |
| Hands-on tool lesson | 5–6 h | 1.5 h | Screen recording and edit: 3–4 h |
| Exercise with files | 4 h | 1 h | Starter and solution files: 2 h |
| Project with rubric | 6–8 h | 2 h | Example solution: 4–8 h |

An entry course of 10–16 lessons therefore takes roughly **80–150 hours** of production. That is why the plan finishes existing courses before opening new ones.

## Notes for authors

- **Accuracy over breadth.** Check commands, shortcuts and menu paths in the current tool version, and state that version in the lesson.
- **Real practice.** Every course produces something the learner can keep or show: a file, a page, a scene, an edit or a portfolio piece.
- **Local relevance.** Use examples and names that make sense to learners in Uzbekistan (Samarqand, local businesses, Uzbek/Russian bilingual design). Choose fonts that support oʻ/gʻ and Cyrillic.
- **Safety and ethics.** Security, AI and media courses teach legal, consent-based practice only. Labs use intentionally vulnerable practice software that runs locally, never real systems.
- **Certificates are honest.** A Mahorat certificate shows completion of a Mahorat course. Where a course is aligned to an industry certification (CompTIA, Cisco, AWS and others), say “aligned with” and never imply the certification itself.
