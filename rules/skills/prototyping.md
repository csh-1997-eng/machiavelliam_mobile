# Prototyping Skill

Load this when: building proof-of-concept, experimenting with ideas, demoing fast, validating hypotheses.

---

## Philosophy

Speed > perfection. Ship fast, learn fast, iterate fast. Don't over-engineer. Don't optimize prematurely. Build the simplest thing that proves the concept.

---

## What to Skip

**Tests:** Skip unless explicitly requested. We'll add tests when solidifying.

**Rigorous Typing:** Basic types fine, but don't create complex type hierarchies.

**Error Handling:** Basic try/except for critical paths (API calls, DB writes), but don't handle every edge case.

**Optimization:** Do NOT optimize. Assume small data, low traffic. We'll scale later.

**Documentation:** Inline comments for non-obvious logic. No formal docs.

**Code Structure:** Flat is fine. One file is fine. Don't architect for scale yet.

---

## What to Prioritize

**Functionality:** Does it work? Does it demo well?

**Clarity:** Can I understand it quickly? Can I modify it easily?

**Visibility:** Add logging for key steps so I can see what's happening.

**Disposability:** Make it easy to throw away. This might not make it to production.

---

## Acceptable Shortcuts

- Hardcode config values (document them as TODOs)
- Use global state if it's simpler
- Skip input validation for internal tools
- Use mock data instead of real APIs
- One massive function instead of clean separation
- Print statements instead of proper logging

---

## When to Stop

If you find yourself:
- Writing tests
- Creating abstractions for future extensibility
- Optimizing performance
- Handling rare edge cases
- Building reusable components

Stop. You're over-engineering. Build the minimal viable demo, then ask if we should harden it.

---

## Deliverable

**Goal:** Working demo in <1 hour. Should reliably show the concept without breaking. Doesn't need to be production-ready.

**Code Quality:** Readable enough that I can modify it. Messy is fine. TODOs are fine.

**Next Steps:** After demo works, explicitly flag: "This is prototype code. To production-ize, we'd need: [list].