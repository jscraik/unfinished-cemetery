---
name: mKit v1
birth: 2024-01
death: 2024-04
cause: architectural-rot
tags: [framework, premature-abstraction]
epitaph: "Premature abstraction is the root of all evil. Build one, then abstract."
---

## What It Wanted To Be

mKit was meant to be a **modular kit system** for building AI-powered applications. The pitch: "Lego blocks for AI apps."

Each "kit" would be:
- A self-contained module
- With its own configuration
- Its own state
- Its own UI components
- Composable with other kits

## The Architecture

I designed a sophisticated plugin system:
- Dynamic kit loading
- Dependency resolution
- Version management
- Hot reloading
- Kit-to-kit communication

I spent weeks on the abstraction layer before writing a single kit that actually did something useful.

## What Actually Happened

I built the framework. Then I tried to build kits with it. The framework fought me. Every real use case broke the abstraction.

I'd designed for flexibility I didn't need and constraints I hadn't anticipated.

## Why It Died

**Premature abstraction.** I generalized from zero examples. The abstractions were elegant and wrong.

**Framework-first thinking.** Instead of building three apps and extracting common patterns, I tried to predict what all apps would need.

**Over-engineering.** Hot reloading? In a v0.1? I was solving problems I might have someday.

## What It Taught Me

1. **Build one, then abstract.** Don't design the framework first. Build the thing, extract the pattern.

2. **Three examples minimum.** Before abstracting, have three concrete use cases. I had zero.

3. **YAGNI is real.** "You Ain't Gonna Need It" — every feature I thought was essential turned out to be unnecessary.

## What Survived

The **kit concept** lives on in my agent-skills, but inverted:
- Skills are concrete, not abstract
- They solve specific problems
- They compose through simple interfaces, not complex frameworks

The lesson, not the code, survived.
