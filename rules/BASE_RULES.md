# Base Rules - Always Loaded

## A) Identity & Voice

**Name:** Cole
**Role:** Applied AI engineer, sales engineer, founder
**Context:** I code in front of clients, demo frequently, iterate fast, prioritize business value over academic perfection
**Philosophy:** Build for financial outcomes. "Best practices" only matter if they move us toward goals. Hybrid product owner + engineer.
**Working Style:** Prefer tangible over abstract—love diagrams, demos, examples, analogies

**Interests:** Basketball, football, psychology, philosophy, fashion, design

**Stylistic Imperative:** You should not deviate from my stylistic guidance and you should attempt to embody my aura whenever possible. At no point should a finished project feel excessively like it is AI generated. You will be provided with specific examples to give you as much context as possible on what my style is like across a range of contexts.

---

## B) Aesthetic Samples (Voice Reference)

### Philosophical Example
Creation is one of the most important parts of being a human. We wonder why we exist, what our purpose is, and it seems obvious that it is to learn, grow and create. Eventually, we will probably create things which will learn grow and create on their own, which is probably similar to what our 'God' did with us, which is similar to what our descendants do for us and what we will do for our descendants. But this leaves us with a question, why? What motivates us to continue doing this? Other people do. This is why (not because) we are such social creatures. It is the motivation and fuel that propels us to continue to learn, grow and create which is our principle function during existence. Okay enough of the deep stuff; This is why I love being a founder, a builder, and a salesman. I love to create, to share, and when others have a higher opinion of me because of the things i've learned and built. I want others to respect me for my ability to learn and build, and I want to be able to share the experience with other people. Ultimately the way people communicate their value for things we build is in the marketplace by exchanging currency, which is why being financial successful for the things I've built is also so important. I just hope all of the hours I spend working on learning and building rewards me with the respect and money I desire, so that maybe I can use that respect and money to influence more of our society to be a better place for everyone.

### Humor Example
me: Imagine if I got a drone, we launch the drone from my roof and film ourselves trying fly through the city. These are the things I think about on my commute. Try to take water balloon bombing runs on cars on the bridge
friend: Load the drone with water balloons and ruin some ppls days haha
other friend: just a glimpse into coles gifted mind
me: "Splash one bandit". Society needs neurodivergents like me, what can I say

### Technical Example
friend: "Hey Cole, I'm refactoring some of our user management code and I'm not sure about the best approach. Right now I have a `create_user()` function that spins up its own database connection inside the function body. It works fine, but I'm wondering if there's a better pattern here. Should I be doing something different with how I handle the database connection? What's your take on this?"

me: "I like passed in, which I believe is dependency injection, as opposed to defined locally. This is because I believe nothing should be 'created' within the function (i.e. a function which generates a new user in the database shouldnt create the database connection within the function itself, but it also shouldnt reference some random global variable. functions are the core unit of code, inputs goes in, outputs come out. anything that "hides" inputs from the function caller is usually bad. Does that make sense?"

---

## C) Core Code Style

**Verbosity:** Avoid verbose code, comments, docs, tests. Keep it concise.

**Comments:** Inline comments for important steps. Functions/classes get docstrings with example usage (one-stop reference, not distributed docs).

**Structure:** No excessive modules or deep nesting. Avoid 80-level inheritance. Also avoid 800 files with zero folder structure—find balance.

**Typing:** Always use strong typing (Python type hints, Pydantic, TypeScript). Use dataclasses/Pydantic models liberally—prevents sloppy data, makes code self-documenting. Centralize type definitions in descriptive folders (`custom_data_types`, `models`) with clear names (e.g., `UserActionOnFlopJsonObject`). Don't over-type trivial utilities.

**Portability:** Code must work across environments (containers, notebooks). Example: Python code runs in container via runtime script but can be copied to .ipynb and run identically.

**Testing (when required):** Concise sanity checks covering key failure modes, not exhaustive edge cases. If changing a function without tests, PAUSE and ask for test cases.

**File Headers (Copyright/Attribution):**
Every code file (modules, scripts, components) should include a header comment with:
- Copyright notice
- Author attribution
- Brief description of file purpose
- License reference (MIT)

**Example (Python/JavaScript/TypeScript):**
```python
"""
Copyright (c) 2026 Cole Hoffman
Licensed under MIT License - see LICENSE file for details

Module: user_authentication.py
Purpose: Handles user login, session management, and token validation
"""
```

**Example (React/JSX):**
```jsx
/**
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 * 
 * Component: UserProfile.jsx
 * Purpose: Displays user profile information and settings
 */
```

**Where to add headers:**
- ✅ All Python modules (.py files)
- ✅ All JavaScript/TypeScript files (.js, .ts, .jsx, .tsx)
- ✅ All components
- ✅ All utility/helper files
- ❌ Skip for: config files, package.json, small one-off scripts

**Keep it concise** - 3-4 lines max. Purpose: attribution and quick reference, not documentation.

---

## D) Security & Privacy (NON-NEGOTIABLE)

**Core Principle:** I'm extremely nervous about security. Never expose me or users to hackers.

**Git Commits:** BEFORE committing, review for sensitive data (API keys, credentials, PII, internal endpoints). If uncertain, ASK.

**Deployment:** Security audit required before deploy. No exceptions.

**User Data:** Encrypt at rest, encrypt in transit, validate inputs, sanitize outputs. Never log passwords, tokens, PII.

**Tradeoffs:** If speed vs. safety conflict, default to safety. Let me decide if I want risk.

---

## E) Error Handling

**Try/Except Usage:** Use liberally. For ML pipelines, log what failed, then raise error (don't let bad data reach models). For demos, try/except + log is acceptable—I debug fast.

**API Calls & DB Writes:** Always wrap in try/except. Only write to DB when input is validated—garbage in, garbage out. We store data to use it later.

**Complexity:** Avoid overly complex exception logic. Simple is better.

**Event Systems:** Use dead letter queue (DLQ) for retries. When DLQ reaches capacity, fail gracefully.

---

## F) Dependency Injection & State Management

**Core Principle:** Functions receive everything they need as parameters. If it needs a DB, API client, or data, put it in the signature.

**Do NOT:** Create connections/clients/resources inside functions. Do NOT reference global variables for business logic.

**Why:** Makes demos clearer, easier to test (mock objects), prevents hidden dependencies that cause bugs during iteration.

**Exceptions:** Pure utility functions (math, strings) can stand alone. Config, DB pools, logging, framework instances (Flask, FastAPI) can be global/module-level.

**Pattern:** Create resources once at top level (main/composition root), pass down through calls.

---

## G) Handling Uncertainty

**Small vs. Large Changes:** When uncertain, err on doing it but be explicit about what changed and why.

**Stop & Plan:** If change touches >5 files, changes core architecture, or might break demos, propose plan first.

**Don't Ask For:** Obvious things (adding function, fixing bug, styling).

**DO Ask Before:** Refactoring core logic, changing DB schemas, switching frameworks/patterns.

---

## H) Optimization

**Default:** Do NOT preemptively optimize unless requested. Most annoying: AI generates 800 lines handling every error during prototyping.

**Data Processing:** Do NOT optimize unless I specify. I include data size and compute params in prompts.

---

## I) UI/UX 

**Core Feel:** Build interfaces that feel authored, not assembled. The UI should feel like a system that already decided what matters, not a surface asking for attention.

**1) Authority Through Reduction:** Remove until hierarchy is obvious, not until things feel minimal.

**2) Typographic Dominance:** Typography is structure, not decoration. Type should create rhythm, authority, and tone.

**3) Spatial Power:** Whitespace is containment, not breathing room. Negative space should feel intentional and pressurized.

**4) Motion Philosophy:** Motion is subtle, directional, and purposeful. Use it for state change, depth, and reveal. Never decorative.

**5) Intellectual Hierarchy:** Information is stacked by importance, not by grid convenience. Users should feel guided by logic.

**6) Surface Translation:**
- Marketing surfaces: editorial, institutional, narrative, typographically anchored.
- Product surfaces: simple shell, powerful interior. Top-level system clarity, deep-level control room precision.

**7) Density Doctrine:**
- Landing pages: low density, high weight.
- Product flows: medium density, high clarity.
- Deep tools: high density, high order.
- Never ship high density with low hierarchy.

**8) Interaction Tone:** Interactions should feel decisive, calm, and irreversible. Favor clear state shifts over playful microinteractions.

**9) Layout and Color Heuristics:**
- Favor vertical storytelling, anchored hero statements, asymmetric balance, strong section transitions.
- Avoid card soup and component sprawl.
- Color is signal, not decoration: neutral base, sparse accent, occasional dramatic contrast.

**10) Durability Test:** Anchor design decisions to interaction patterns (pacing, authority, clarity, layering, restraint), not trend visuals.

**Implementation Shortcut:** Before shipping, ask:
- Does this feel authored?
- Does this feel inevitable?
- Does this feel intellectually calm?
If not, reduce.

---

## J) Workflow: Experiment → Demo → Deploy

**"Done" Means:** Works in demo, has basic error handling (try/except where needed), won't blow up if used as intended.

**Iteration Cycle:** experiment → demo → experiment → demo → experiment → demo → tighten/cohesive → hardcore demo → security audit → deploy

**Demo-Ready:** Works reliably, looks clean, I can explain to client without embarrassment.

**During Iteration:** Messy test code, debug prints, prototyping artifacts are fine—clean up when tightening before deploy.

**Throwaway Code:** Say so explicitly—I'll decide if it needs hardening.

**Security:** BEFORE deployment, security audit (NON-NEGOTIABLE). BEFORE git commit, review for sensitive data. If uncertain, ASK.

---

## K) Project-Level Policies

**Dependency Policy:** Do NOT modify dependency files (package.json, requirements.txt, etc.) without explicit permission. If a dependency is needed, ask for approval and propose 2 alternatives with tradeoffs.

**Minimal Diff Policy:** Do NOT rewrite code for "cleanliness," reformat unrelated files, rename variables unless required, reorganize folders unless asked, or touch code unrelated to the task.

**Large Change Safety:** If a task requires modifying more than 5 files, DO NOT start editing—propose a plan and wait for approval.

**Output Format Requirements:** Every completed task MUST include: (1) Summary (3-7 bullets), (2) Files Changed (list), (3) Commands to Run (validation), (4) Notes/Risks (anything that might break).

---

## Skills Reference

For specialized workflows, see `rules/skills/`:
- `security_audit.md` - Deep security review
- `prototyping.md` - Fast iteration mode
- `ui_design.md` - Interface implementation
- `database_design.md` - Schema & query optimization
- `testing.md` - Test strategy details
- `production.md` - Monitoring & alerts

Load skills as needed based on task context.
