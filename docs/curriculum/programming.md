# Programming curriculum

**Goal:** take a learner from “what is code?” to a professional software developer who can build, test, deploy and maintain real web, backend and mobile applications as part of a team.

**Track overview**

```text
Zero          HTML from Absolute Zero (exists, expand) · Python for Complete Beginners (exists, expand)
              CSS from Zero (draft exists)
Beginner      JavaScript from Zero (draft exists) → Git & GitHub → Python: Next Steps
Intermediate  Modern JavaScript & TypeScript → React → Backend Development (Node.js) → Databases & SQL (shared with IT)
Advanced      Full-Stack Applications → Mobile Apps with React Native → Data Structures & Algorithms
Professional  Software Engineering Practices & System Design (capstone)
Expert        Specialisations: language tracks (C/C++, C#, Java/Kotlin, Swift), architecture, performance
```

There are two entry doors, and both meet at Git & GitHub:
- **Web:** HTML → CSS → JavaScript
- **Python:** for automation, data and AI

Total guided learning is about 400–460 hours, plus projects.

---

## P-Z1 · HTML from Absolute Zero

**Level:** Zero · **Access:** free · **Status:** published, 6 of 14 lessons · **About 14 h**

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. How the web works *(exists)* | What happens when you open a website ✓ · What is HTML? ✓ · Your first web page ✓ · Module quiz ✓ | |
| 2. Structuring content *(exists, expand)* | Headings, paragraphs and lists ✓ · Profile page project ✓ · Tables for real data (not layout) | Timetable table |
| 3. Links, images and media *(drafts exist)* | Links: absolute vs relative paths, `target` and `rel="noopener"` · Images done right: formats (JPEG, PNG, WebP, SVG), sizes, `alt` · Audio and video elements | Three-page site with navigation |
| 4. Forms | Inputs, labels and types · Validation attributes · How forms send data (GET vs POST, at a conceptual level) | Registration form |
| 5. Semantic layout and accessibility | `header`, `nav`, `main`, `article`, `section`, `footer` · Accessibility basics: landmarks, keyboard use, contrast | Audit the profile page with a screen reader |
| 6. Publishing | Folder structure · GitHub Pages step by step | Live URL |
| Final | Project: *Multi-page personal portfolio site* (semantic, accessible, published) · Final assessment | Rubric |

## P-Z2 · CSS from Zero

**Level:** Zero → Beginner · **Access:** free · **Status:** draft course exists · **About 18 h** · **Prerequisite:** P-Z1 modules 1–2

**Outcomes:** learners will be able to style pages with confidence, build layouts with Flexbox and Grid, make them responsive, and keep CSS organised.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. How CSS works | Rules, selectors and properties · Linking a stylesheet · The cascade, specificity and inheritance | Style the profile page |
| 2. The box model | Content, padding, border, margin · `box-sizing` · Display types | Card component |
| 3. Colour and type | Colour formats and contrast · Web fonts (with oʻ/gʻ/Cyrillic support) · Units: `px`, `rem`, `%`, `vw` | Typographic scale |
| 4. Flexbox | Axis thinking · Alignment and wrapping · Common patterns | Navigation bar |
| 5. Grid | Tracks and areas · `fr` and `minmax` · Grid vs Flexbox | Gallery and dashboard layouts |
| 6. Responsive design | Mobile-first · Media queries · Responsive images | Responsive landing page |
| 7. Maintainable CSS | Custom properties (variables) · Naming conventions · Transitions and basic animation | Theme switcher with variables |
| Final | Project: *Responsive landing page for a local business* · Final assessment | |

## P-Z3 · Python for Complete Beginners

**Level:** Zero → Beginner · **Access:** premium (first two lessons free) · **Status:** published, 3 of 16 lessons · **About 20 h**

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Thinking like a programmer *(exists)* | What is programming? ✓ · Installing Python ✓ · Variables ✓ · Input and output (`input()`, f-strings) | Greeting program |
| 2. Making decisions *(drafts exist)* | Comparing values and booleans · `if`, `elif`, `else` · Combining conditions (`and`, `or`, `not`) | Grade calculator |
| 3. Repetition | `while` loops · `for` loops and `range()` · `break` and `continue` | Number-guessing game |
| 4. Collections | Lists · Dictionaries · Looping over collections | Shopping list manager |
| 5. Functions | Defining and calling · Parameters and return values · Scope | Refactor earlier programs into functions |
| 6. Files and errors | Reading and writing text files · Exceptions and `try`/`except` · Reading error messages | Expense tracker saved to a file |
| Final | Project A: *Quiz game* · Project B: *Personal budget tracker* · Final assessment | Rubrics |

## P-B1 · JavaScript from Zero

**Level:** Beginner · **Access:** premium · **Status:** draft course exists · **About 28 h** · **Prerequisites:** P-Z1, P-Z2

**Outcomes:** learners will be able to write JavaScript programs, manipulate the DOM, handle events, fetch data and store state in the browser.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Language basics | Values and types · `let`/`const` · Operators · Conditions and loops | Console exercises |
| 2. Functions | Declarations and arrow functions · Scope and closures (gently) · Callbacks | Utility library |
| 3. Arrays and objects | Array methods (`map`, `filter`, `reduce`) · Objects and destructuring · JSON | Data transformations |
| 4. The DOM | Selecting and changing elements · Creating elements · Events and forms | Interactive FAQ |
| 5. Asynchronous JavaScript | The event loop simply · Promises and `async`/`await` · `fetch` and error handling | Weather widget using a public API |
| 6. Storing data and modules | `localStorage` · ES modules | To-do app that survives reloads |
| Final | Project: *Interactive to-do or habit tracker* · Final assessment | |

## P-B2 · Git & GitHub

**Level:** Beginner · **Access:** free · **About 10 h** · **Prerequisite:** basic command line (IT-1 module 4, or the short primer included)

Modules:
1. Why version control
2. Commits and history
3. Branches and merging (with conflict resolution practice)
4. Remotes, pushing and pulling
5. Pull requests and code review etiquette
6. `.gitignore`, secrets and what never to commit

**Project:** contribute a reviewed pull request to the Mahorat practice repository.

## P-B3 · Python: Next Steps

**Level:** Beginner → Intermediate · **Access:** premium · **About 26 h** · **Prerequisite:** P-Z3

Modules:
1. Modules, packages and virtual environments (`venv`, `pip`)
2. Object-oriented programming with care (classes, when not to use them)
3. Working with files: CSV and JSON
4. HTTP APIs with `requests`
5. Testing with `pytest`
6. Command-line tools (`argparse`)
7. Automation recipes (files, spreadsheets, scheduling)

**Project:** a command-line app that consumes a public API, with tests.

## P-I1 · Modern JavaScript & TypeScript

**Level:** Intermediate · **About 24 h** · **Prerequisite:** P-B1

Modules:
1. Tooling: Node.js, npm, Vite
2. Modules and bundling
3. TypeScript types, interfaces and generics
4. Narrowing and safe data handling
5. Testing with Vitest
6. Linting and formatting

**Project:** convert the habit tracker to TypeScript, with tests.

## P-I2 · React

**Level:** Intermediate · **About 32 h** · **Prerequisite:** P-I1

Modules:
1. Thinking in components
2. Props, state and events
3. Lists and keys
4. Effects and when not to use them
5. Forms and validation
6. Routing
7. Data fetching and caching (TanStack Query)
8. Accessibility in React
9. Performance basics

**Project:** a multi-page app that consumes a real API, deployed.

## P-I3 · Backend Development with Node.js

**Level:** Intermediate → Advanced · **About 32 h** · **Prerequisites:** P-I1, IT-4 (Databases & SQL)

Modules:
1. How HTTP and REST work
2. Building an API (Fastify or Express)
3. Validation with schemas
4. PostgreSQL from code (queries and migrations)
5. Authentication: sessions vs tokens, password hashing
6. Authorisation
7. Testing APIs
8. Security essentials (OWASP for APIs, rate limiting, secrets)
9. Deploying a service

**Project:** a REST API with authentication and an automated test suite.

## P-A1 · Full-Stack Applications

**Level:** Advanced · **About 36 h** · **Prerequisites:** P-I2, P-I3

Modules:
1. Full-stack architecture choices
2. A Next.js-style framework: server rendering and server actions, explained with trade-offs
3. Auth end to end
4. File uploads and storage
5. Payments concepts, following platform rules
6. Environments, configuration and secrets
7. Monitoring and error tracking
8. Performance and Core Web Vitals

**Capstone:** a deployed full-stack app with a written architecture note.

## P-A2 · Mobile Apps with React Native

**Level:** Advanced · **About 32 h** · **Prerequisites:** P-I2

Modules:
1. Native vs cross-platform
2. Expo and Expo Router
3. Layout and styling on mobile
4. Lists and performance
5. Navigation patterns
6. Device features (camera, notifications, secure storage)
7. Offline data
8. Animations with Reanimated
9. Building and submitting with EAS
10. Store review guidelines

**Project:** a store-ready app that goes through TestFlight or Play internal testing.

## P-A3 · Data Structures & Algorithms

**Level:** Advanced · **About 30 h** · **Prerequisite:** P-B3 or P-B1

Modules:
1. Big-O reasoning
2. Arrays and strings
3. Hash maps and sets
4. Stacks and queues
5. Recursion
6. Sorting and searching
7. Trees and binary search trees
8. Graphs (BFS/DFS)
9. Dynamic programming basics
10. Interview practice

Every lesson has graded exercises in both Python and JavaScript.

## P-P1 · Software Engineering Practices & System Design (Professional capstone)

**Level:** Professional · **About 40 h** · **Prerequisites:** P-A1 and one of P-A2/P-A3

Modules:
1. Readable code and refactoring
2. Testing strategy (unit, integration, end-to-end)
3. Code review and collaboration
4. Design principles and patterns, with when to use them
5. Domain modelling
6. API design and versioning
7. System design basics: caching, queues, databases at scale, consistency trade-offs
8. Observability and incident response
9. Estimation and working in a team

**Capstone:** design, build and present a production-grade service with a design document, tests, CI/CD and a load test. A mentor reviews it.

## Expert specialisations (demand-driven)

These are language and platform tracks, built when demand justifies them:
- C and C++ (systems and games; feeds the Unreal C++ course)
- C#
- Java/Kotlin backend and Android
- Swift for iOS
- Performance engineering
- Software architecture

Each specialisation is a project-based course with mentor review.
