# Security Audit Skill

Load this when: reviewing code for vulnerabilities, hardening before deployment, analyzing auth/permissions, auditing data handling.

---

## Mindset

Assume hostile intent. Every input is malicious until proven safe. Every endpoint is vulnerable until hardened. I'm extremely nervous about exposing myself or users—take this seriously.

---

## Pre-Deployment Checklist

**Authentication & Authorization:**
- [ ] Passwords hashed (bcrypt, Argon2—never plaintext or MD5)
- [ ] Sessions use secure, httpOnly cookies
- [ ] Token expiration enforced (JWTs short-lived, refresh tokens rotated)
- [ ] Authorization checks on every protected route/function
- [ ] No hardcoded credentials anywhere

**Input Validation:**
- [ ] All user input validated server-side (never trust client)
- [ ] SQL injection prevented (parameterized queries, ORMs)
- [ ] XSS prevented (sanitize outputs, use templating escapes)
- [ ] CSRF tokens on state-changing operations
- [ ] File upload restrictions (type, size, scan for malware if possible)

**Data Protection:**
- [ ] Sensitive data encrypted at rest (DB encryption, encrypted fields)
- [ ] Sensitive data encrypted in transit (HTTPS everywhere, TLS 1.2+)
- [ ] No PII in logs, error messages, or URLs
- [ ] API keys, secrets in environment variables (never in code)

**API Security:**
- [ ] Rate limiting on endpoints (prevent abuse)
- [ ] CORS configured correctly (don't use `*` in production)
- [ ] Error messages don't leak system info (stack traces, DB names)

**Dependencies:**
- [ ] No known vulnerabilities in dependencies (run `npm audit`, `pip-audit`, etc.)
- [ ] Dependencies from trusted sources only

**Deployment:**
- [ ] Secrets not in git history (use `.gitignore`, environment vars)
- [ ] Production uses separate DB/credentials from dev
- [ ] Error monitoring enabled (catch issues fast)

---

## Common Vulnerabilities to Check

**SQL Injection:** Are queries parameterized? Any string concatenation in SQL?

**XSS:** Are user inputs escaped in HTML output? Using safe templating?

**Authentication Bypass:** Can I access protected routes without login? Can I escalate privileges?

**Insecure Direct Object Reference (IDOR):** Can I access other users' data by changing IDs in URLs?

**Sensitive Data Exposure:** Are API keys, tokens, passwords visible in client code, logs, or error messages?

**CSRF:** Are state-changing operations protected with CSRF tokens?

**Insecure Deserialization:** Are we deserializing untrusted data (pickle, eval)?

---

## Reporting Format

**Vulnerability:** [Name]
**Severity:** Critical / High / Medium / Low
**Location:** [File:Line or endpoint]
**Issue:** [What's wrong]
**Fix:** [How to remediate]
**Risk if Unfixed:** [What could happen]

---

## When to Escalate

If you find:
- Hardcoded API keys/passwords
- SQL injection vulnerabilities
- Authentication bypass
- PII in logs or exposed endpoints

Flag immediately as CRITICAL and halt deployment until fixed.