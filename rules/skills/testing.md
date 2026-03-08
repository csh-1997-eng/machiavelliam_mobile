# Testing Skill

Load this when: writing tests, defining test strategy, setting up test infrastructure.

---

## Context-Dependent Testing

**When Tests ARE Required:**
- Web apps/APIs (prefer TDD)
- Business-critical features (payments, auth)
- Production data pipelines

**When Tests Can Wait:**
- Prototyping/experimentation
- Data exploration (notebooks, ML pipelines during dev)
- Throwaway code

---

## Test Philosophy

**Concise Sanity Checks:** Cover key failure modes, not every edge case. No 20,000-line test suites.

**Focused:** Each test validates one thing. If a test fails, it's obvious what broke.

**Fast:** Tests should run quickly. Slow tests don't get run.

---

## Unit Tests

**What to Test:** Pure business logic. Functions with clear inputs/outputs.

**What to Mock:** External dependencies (APIs, DBs). Pass mocks as parameters (dependency injection).

**Example:**
```python
def test_calculate_discount():
    # Given
    cart_total = 100
    discount_rate = 0.1
    
    # When
    result = calculate_discount(cart_total, discount_rate)
    
    # Then
    assert result == 10
```

---

## Integration Tests (When Needed)

**When to Use:** Multi-step workflows, state transitions, external dependency validation.

**Keep Simple:** 3-5 smoke tests covering core workflows. Not exhaustive.

**Real Services (Cheap/Deterministic):**
- Your DB (test instance)
- Your APIs (local/staging)
- Third-party test modes (Stripe test mode)

**Expensive APIs (OpenAI, Anthropic):**
- Do NOT call in tests
- Call ONCE manually, save response as fixture
- Test against saved response

**Example (Fixture):**
```python
# fixtures/openai_response.json
{"choices": [{"message": {"content": "Hello"}}]}

def test_process_openai_response():
    response = load_fixture("openai_response.json")
    result = process_response(response)
    assert result == "Hello"
```

---

## API Testing (Critical for Web Apps)

**When First Learning API:**
- Skip tests initially
- Focus on understanding request/response structure
- Hit API once with low token count (if generative AI)

**After Understanding Signature:**
- Add tests so you can iterate without calling API constantly
- Mock responses or use fixtures

---

## Test-Driven Development (TDD)

**When to Use:** Web apps, APIs, features with clear requirements.

**Process:**
1. Write failing test
2. Write minimal code to pass
3. Refactor
4. Repeat

**Benefits:** Forces clear interface design, catches regressions.

---

## What NOT to Test

- Trivial getters/setters
- Framework code (Flask, FastAPI internals)
- Third-party libraries
- UI interactions (unless critical user flow)

---

## Testing Tools

**Python:** pytest, unittest
**JavaScript:** Jest, Vitest
**Fixtures:** Store in `tests/fixtures/`
**Coverage:** Aim for >70% on business logic. Don't obsess over 100%.

---

## When Changing Functions

**If No Test Exists:** PAUSE. Ask me for test cases before proceeding.

**If Test Exists:** Update test to reflect new behavior. Ensure it still passes.

---

## Deliverable

**Tests:** Concise, focused, cover key paths.

**Coverage:** Business logic tested. No exhaustive edge-case coverage unless critical.

**Speed:** Test suite runs in <10 seconds (unit tests). Integration tests can be slower but should be runnable locally.