# Unreal Engine & game development curriculum

**Goal:** take a learner who knows basic computer use to a professional who can design, build, optimise and ship a game or real-time experience in Unreal Engine, working with Blueprints and C++ in a team.

**Track overview**

```text
Beginner      Unreal Engine Fundamentals (exists: 1 of 10 lessons, complete first) → Blueprint Visual Scripting → Level Design Fundamentals
Intermediate  Materials & Lighting · Landscapes & Environments · Gameplay Framework & UI · Animation & Characters
Advanced      C++ for Unreal · Niagara VFX · Game AI · Optimisation & Profiling · Multiplayer Fundamentals
Professional  Complete Game Production (capstone)
Expert        Specialisations: technical design · tools programming · real-time cinematics / virtual production
```

**Recommended before this track:**
- *Computer Fundamentals from Zero*
- *Blender: Your First Steps in 3D*, so that 3D concepts are already familiar
- For C++, the Programming track up to *Python: Next Steps*, or *JavaScript from Zero*

Total guided learning is about 380–430 hours, plus projects. Every course states the Unreal Engine 5.x version used.

---

## U-1 · Unreal Engine Fundamentals

**Level:** Beginner · **Access:** premium (first lesson free) · **Status:** published, 1 of 10 lessons, no assessment yet. **Highest priority to finish** (see the content audit). **About 12 h**

**Outcomes:** learners will be able to explain what an engine provides, install Unreal safely, find their way around the editor, place and edit actors, apply materials and lights, and package a playable build.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Getting started | What is a game engine? ✓ · **Installing Unreal Engine** (spec below) · **A tour of the editor** (spec below) | First project opened, viewport navigation drill |
| 2. Building a scene | Actors, components and the Details panel · Static meshes, transforms and snapping · Importing assets (FBX/glTF from Blender; Fab content and licences) | Recreate a reference room from basic shapes |
| 3. Look and feel | Materials and material instances (intro) · Lights, Lumen and post-process (intro) | Day and night versions of the room |
| 4. Making it playable | Play in Editor, Simulate and the player start · Packaging a build and project settings | Packaged build that runs outside the editor |
| Final | Module quizzes (one per module) · Project: *Explorable diorama* (walkable level with materials and lighting, packaged) · Final assessment | Rubric |

### Lesson spec: Installing Unreal Engine (in review, finish first)

1. **Is my computer ready?**
   - Link the official *Hardware and Software Specifications* page for the version taught, and explain how to read it.
   - Practical guidance: a 64-bit OS, a recent multi-core CPU, a dedicated GPU with current drivers for Lumen and Nanite, 16 GB RAM as a workable minimum (32 GB is comfortable), and an SSD with plenty of free space (the engine plus a project can take tens of gigabytes).
   - Explain what to expect on laptops and on integrated graphics.
2. **Epic Games account and Launcher.** Download only from the official site, sign in, then open the **Unreal Engine** tab → **Library** → add an engine version → choose the install folder and optional components (with what each is for).
3. **Licence awareness.** Learning is free. For commercial releases, read Epic's current EULA (royalty terms change; do not quote figures without the date).
4. **First project.** Templates (Blank, First Person, Third Person), Blueprint vs C++ project, quality preset, starter content, and where the project folder lives.
5. **When things go wrong:** shader compilation on first open (normal and slow), out of disk space, GPU driver issues.
6. **Knowledge check:** five questions.

### Lesson spec: A tour of the editor (draft)

1. Main areas: **Viewport**, **Outliner**, **Details**, **Content Drawer** (Ctrl + Space), toolbar (Play, Simulate, Build), and the **Quickly add to the project** menu for placing actors.
2. Viewport navigation: right mouse button + WASD to fly, F to focus, Alt + drag to orbit, speed setting. Compare with Blender navigation.
3. Selecting and transforming actors (W, E, R), local vs world space, snapping.
4. Saving levels vs saving assets, and project organisation conventions for folders and naming.
5. Practice: a guided "find it" tour with 10 tasks and an expected result for each.

## U-2 · Blueprint Visual Scripting

**Level:** Beginner → Intermediate · **About 30 h** · **Prerequisite:** U-1

Modules:
1. How Blueprints think: events, execution flow, data pins
2. Variables, types and functions
3. Flow control (branch, loops, gates)
4. Blueprint classes, components and construction scripts
5. Communication: casting, interfaces, event dispatchers
6. Timelines and simple animation
7. Enhanced Input
8. Debugging Blueprints
9. Organising graphs for teams

**Project:** an interactive puzzle room with doors, switches, pickups and a win condition.

## U-3 · Level Design Fundamentals

**Level:** Beginner → Intermediate · **About 20 h** · **Prerequisite:** U-1 (U-2 recommended)

Modules:
1. The role of a level designer
2. Metrics: player size, jump height, corridor widths
3. Blockout with modeling tools
4. Guiding players: landmarks, light and composition
5. Pacing and encounter design
6. Playtesting and iteration

**Project:** a blockout level with a design document and playtest notes.

## U-4 · Materials & Lighting

**Level:** Intermediate · **About 26 h** · **Prerequisite:** U-1

Modules:
1. Material editor in depth (PBR)
2. Master materials and instances
3. Texture workflows from Blender and other tools
4. Lighting: directional, sky and local lights
5. Lumen global illumination and reflections
6. Nanite and what it changes
7. Post-process and exposure
8. Performance cost of lighting choices

**Project:** an interior lit for day, night and a mood shot.

## U-5 · Landscapes & Environments

**Level:** Intermediate · **About 26 h** · **Prerequisite:** U-4

Modules:
1. Landscape sculpting and layers
2. Landscape materials and auto-material basics
3. Foliage and scattering
4. Procedural tools (the PCG framework; check its status in the engine version taught)
5. World Partition for large worlds
6. Atmosphere: sky, fog and clouds

**Project:** an open environment vista with a gameplay path.

## U-6 · Gameplay Framework & UI

**Level:** Intermediate · **About 30 h** · **Prerequisite:** U-2

Modules:
1. GameMode, GameState, PlayerController, Pawn and Character: who owns what
2. Health, damage and scoring systems
3. UMG user interface: HUD, menus, settings
4. Save and load
5. Audio basics
6. Game loop: start, win, lose, restart

**Project:** a small complete game (5–10 minutes of play) with menus and saving.

## U-7 · Animation & Characters

**Level:** Intermediate → Advanced · **About 28 h** · **Prerequisites:** U-6 (Blender B-7 recommended)

Modules:
1. Skeletal meshes and import from Blender
2. Animation Blueprints and state machines
3. Blend spaces
4. Montages and notifies
5. Retargeting
6. Control Rig basics
7. Digital humans (overview of MetaHuman workflows and their licence terms)

**Project:** a playable character with locomotion, jump and an interaction animation.

## U-8 · C++ for Unreal

**Level:** Advanced · **About 40 h** · **Prerequisites:** U-2, plus C++ fundamentals (a short C++ primer is included as module 0)

Modules:
1. C++ essentials for Unreal: classes, pointers and references, headers
2. Unreal's reflection system: `UCLASS`, `UPROPERTY`, `UFUNCTION`
3. Actors and components in C++
4. Exposing C++ to Blueprints, and the hybrid workflow
5. Memory management and garbage collection
6. Delegates and interfaces
7. Debugging with an IDE
8. Gameplay Ability System (overview)

**Project:** rebuild a gameplay system from U-6 in C++, exposed to designers.

## U-9 · Niagara VFX

**Level:** Advanced · **About 20 h** · **Prerequisite:** U-4

Modules:
1. Particles and emitters
2. Modules and parameters
3. Sprites, meshes and ribbons
4. Collisions and events
5. Materials for VFX
6. Performance budgets

**Project:** a VFX pack (fire, magic hit, ambient dust) used in gameplay.

## U-10 · Game AI

**Level:** Advanced · **About 22 h** · **Prerequisite:** U-6

Modules:
1. Navigation mesh
2. AI Controller and Perception
3. Behaviour Trees and Blackboards
4. Environment Query System
5. State Trees (overview)
6. Designing fair and readable enemies

**Project:** guards that patrol, investigate noise and chase.

## U-11 · Optimisation & Profiling

**Level:** Advanced · **About 22 h** · **Prerequisites:** U-4, U-6

Modules:
1. Frame budgets and targets
2. `stat` commands and Unreal Insights
3. CPU vs GPU bound
4. Draw calls, instancing, LODs and HLOD
5. Cost of Lumen and Nanite, and alternatives
6. Memory and streaming
7. Packaging and platform settings

**Project:** take a slow provided level to a target frame rate, with a profiling report.

## U-12 · Multiplayer Fundamentals

**Level:** Advanced · **About 24 h** · **Prerequisites:** U-6 (U-8 recommended)

Modules:
1. Client–server model and authority
2. Replication of properties
3. RPCs
4. Network relevancy and bandwidth
5. Testing with multiple clients
6. Sessions overview

**Project:** a two-player co-op prototype.

## U-P · Complete Game Production (capstone)

**Level:** Professional · **About 50 h** plus a team project · **Prerequisites:** U-6 and two Advanced courses

Modules:
1. From idea to game design document
2. Scope and milestones
3. Vertical slice
4. Source control for Unreal projects (Git LFS or Perforce concepts)
5. Playtesting and analytics
6. Polish: game feel, audio and UI
7. Accessibility in games
8. Store requirements and builds
9. Legal: licences for engine, assets, fonts and music
10. Launch and post-launch

**Capstone:** ship a small, polished game, alone or in a team of 2–4, with a post-mortem. Mentors review it at each milestone.

## Expert specialisations

- **Technical design:** systems design, data-driven gameplay.
- **Tools programming:** editor utilities, automation.
- **Real-time cinematics / virtual production:** Sequencer, camera work, rendering.
