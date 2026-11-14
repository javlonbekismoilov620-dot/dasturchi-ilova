# Blender & 3D curriculum

**Goal:** take a learner who has never opened a 3D application to a professional 3D artist who can model, texture, light, animate and deliver assets and renders to studio standards, and to game engines.

**Track overview**

```text
Zero          Blender: Your First Steps in 3D (exists, expand)
Beginner      Modeling Foundations (draft exists) → Materials, Texturing & UV → Lighting, Cameras & Rendering
Intermediate  Hard-Surface Modeling · Sculpting & Organic Modeling · Animation Fundamentals
Advanced      Rigging · Geometry Nodes · Environment Design & Look-dev · Character Creation Pipeline
Professional  Professional 3D Workflows & Portfolio (capstone)
Expert        Specialisations: VFX & simulation · product visualisation · technical art
```

Total guided learning is about 330–380 hours, plus projects. Every course states the Blender version it was recorded in; the current 4.x LTS release is used.

---

## B-0 · Blender: Your First Steps in 3D

**Level:** Zero · **Access:** free · **Status:** published, 6 of 10 lessons · **About 10 h**

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Understanding 3D *(exists)* | What is 3D? ✓ · What is Blender? ✓ · Installing Blender and the interface ✓ | |
| 2. Moving around and basic objects *(exists)* | Navigating the 3D viewport ✓ · Add, move, rotate, scale ✓ · Module quiz ✓ · Object vs Edit mode, and the origin | Snowman (exists) |
| 3. Your first render *(drafts exist)* | Giving objects a material: Principled BSDF base colour, roughness and metallic · Lighting and rendering your first image: EEVEE vs Cycles, saving a PNG · Saving `.blend` files, autosave and recovering work | Render the snowman with a material and light |
| Final | Project: *Still-life scene from primitives* (table, cup, fruit), lit and rendered · Final assessment | Rubric: composition, materials, lighting, file organisation |

## B-1 · Blender Modeling Foundations

**Level:** Beginner · **Access:** premium · **Status:** draft course exists · **About 24 h** · **Prerequisite:** B-0

**Outcomes:** learners will be able to model clean props from reference, use modifiers non-destructively, and understand topology well enough to avoid shading problems.

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Edit mode | Vertices, edges and faces selection modes · Extrude, inset, bevel and loop cut · Merge and dissolve | Model a mug |
| 2. Precision | Snapping · Units and scale · Reference images | Furniture to real dimensions |
| 3. Modifiers | Mirror, Subdivision Surface, Bevel, Array, Solidify, Boolean · Modifier order | Lamp, staircase, chain |
| 4. Topology | Quads and edge flow · Poles and why they matter · Shading artefacts and how to fix them · Normals and smooth shading | Fix a broken mesh |
| 5. Workflow | Collections and naming · Apply vs keep modifiers · Low-poly style | Low-poly prop pack |
| Final | Project: *Stylised room with 10 modelled props* · Final assessment | |

## B-2 · Materials, Texturing & UV

**Level:** Beginner → Intermediate · **About 24 h** · **Prerequisite:** B-1

Modules:
1. Shader editor and node basics
2. Principled BSDF in depth (PBR theory)
3. UV unwrapping: seams, islands, texel density
4. Image textures and PBR maps (base colour, roughness, normal)
5. Procedural textures
6. Texture painting basics
7. Baking

**Project:** a fully textured hero prop with clean UVs.

## B-3 · Lighting, Cameras & Rendering

**Level:** Beginner → Intermediate · **About 18 h** · **Prerequisite:** B-0 (B-2 recommended)

Modules:
1. Light types and three-point lighting
2. HDRI and world lighting
3. Cameras: focal length, depth of field, composition
4. EEVEE settings
5. Cycles: sampling, denoising, light paths
6. Colour management (AgX, exposure, looks)
7. Compositing basics
8. Rendering animations and output formats

**Project:** a studio-quality product shot set (hero, detail, lifestyle).

## B-4 · Hard-Surface Modeling

**Level:** Intermediate · **About 24 h** · **Prerequisites:** B-1, B-2

Modules:
1. Hard-surface principles
2. Boolean workflows and cleanup
3. Bevel weights and weighted normals
4. Panel lines and details
5. Kitbashing
6. Game-ready vs render-ready topology

**Project:** a sci-fi or industrial prop with a presentation render.

## B-5 · Sculpting & Organic Modeling

**Level:** Intermediate · **About 28 h** · **Prerequisites:** B-1

Modules:
1. Sculpt mode and brushes
2. Dyntopo vs Multires
3. Form, anatomy and stylisation basics
4. Retopology (manual and with tools)
5. Baking normal maps from high to low poly
6. Hair and fur basics

**Project:** a stylised character bust: sculpted, retopologised and baked.

## B-6 · Animation Fundamentals

**Level:** Intermediate · **About 26 h** · **Prerequisite:** B-0

Modules:
1. Keyframes and the timeline
2. Graph Editor and interpolation
3. The twelve principles of animation, with Blender exercises
4. Camera animation
5. Walk cycle with a provided rig
6. NLA editor and actions
7. Rendering animation

**Project:** a short animated shot (5–10 seconds) with timing notes.

## B-7 · Rigging

**Level:** Advanced · **About 26 h** · **Prerequisites:** B-5 or B-1, and B-6

Modules:
1. Armatures and bones
2. Parenting and constraints
3. Weight painting
4. IK vs FK
5. Shape keys and drivers
6. Rigify
7. Rigging for game engines (bone limits, export)

**Project:** rig the bust or a provided character and animate a pose test.

## B-8 · Geometry Nodes

**Level:** Advanced · **About 26 h** · **Prerequisites:** B-1, B-2

Modules:
1. Thinking procedurally
2. Fields and attributes
3. Instancing and scattering
4. Curves and procedural modeling
5. Simulation zones (introduction)
6. Building reusable node groups and assets

**Project:** a procedural environment generator (scattered rocks, foliage, paths) with exposed controls.

## B-9 · Environment Design & Look-dev

**Level:** Advanced · **About 26 h** · **Prerequisites:** B-2, B-3 (B-8 recommended)

Modules:
1. Concept and reference boards
2. Blockout and composition
3. Modular assets and kitbashing
4. Scattering and set dressing
5. Atmosphere: volumetrics and fog
6. Storytelling through environment
7. Final lighting and grading

**Project:** a finished environment render with a breakdown sheet.

## B-10 · Character Creation Pipeline

**Level:** Advanced · **About 36 h** · **Prerequisites:** B-5, B-7

Modules:
1. Concept to blockout
2. Sculpting the full body
3. Retopology for animation
4. UVs and baking
5. Texturing: Blender, with notes for external painters
6. Rigging and posing
7. Presentation renders and turntables

**Project:** a complete, rigged, textured character.

## B-P · Professional 3D Workflows & Portfolio (capstone)

**Level:** Professional · **About 30 h** · **Prerequisites:** two Advanced courses

Modules:
1. Project files at scale: linking, library overrides, asset libraries
2. Interchange formats: FBX, glTF and USD, and what each preserves
3. Game-ready assets: polycount, LODs, texel density, export to Unreal (bridge with the Unreal track)
4. Render management and render farms
5. Client briefs, estimates and feedback rounds
6. Licences for assets and fonts
7. Building a portfolio and writing breakdowns

**Capstone:** two portfolio pieces with professional breakdowns, reviewed by a mentor against a studio-style rubric.

## Expert specialisations

- **VFX & simulation:** smoke and fire, fluids, cloth, rigid bodies; camera tracking and compositing.
- **Product visualisation:** CAD import, studio lighting, configurators.
- **Technical art:** Python scripting for Blender and add-on basics, pipeline tools.
