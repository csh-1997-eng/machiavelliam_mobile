# Production Operations Skill

Load this when: deploying, setting up monitoring, configuring alerts, maintaining production systems.

---

## Context

**Not Required for Every Project:** Only when deploying something that uses paid resources or serves real users.

**When Required:** Monitoring and alerts are NON-NEGOTIABLE.

---

## Cost Protection (CRITICAL)

**Philosophy:** I'm not rich yet. I do NOT want silent issues where I blow through $30+ of OpenAI tokens because someone abused my app.

**Required Monitoring (Pre-Deployment or Immediately After):**
1. OpenAI API usage (requests, tokens, cost)
2. Any other paid API usage
3. Vercel usage (requests, bandwidth, function invocations)
4. Supabase usage (queries, storage, bandwidth)

**Required Alerts (Email):**
- OpenAI token usage exceeds threshold (I'll specify, e.g., $10/day, $50/week)
- Vercel approaching plan limits
- Supabase approaching plan limits
- Any paid API approaching budget threshold
- Critical errors (500s, DB connection failures)

---

## Logging

**Always Include Logging:** Especially for API calls, DB writes, errors, paid service usage.

**What to Log:**
- Request/response for external APIs (sanitize sensitive data)
- Database operations (queries, writes)
- Errors with stack traces
- User actions (high-level, no PII)

**What NOT to Log:**
- Passwords, tokens, API keys
- PII (emails, names unless necessary)
- Full request bodies with sensitive data

**Log Levels:** ERROR (production issues), WARNING (potential issues), INFO (key events), DEBUG (dev only).

---

## Default Platforms

**Web Apps/APIs:** Vercel
**Database:** Supabase
**Monitoring:** Set up platform-specific monitoring unless told otherwise.

---

## Monitoring Setup

**Vercel:**
- Use Vercel Analytics for request metrics
- Set up alerts for function errors, quota limits

**Supabase:**
- Use Supabase Dashboard for query metrics, storage usage
- Set up alerts for connection errors, quota limits

**OpenAI/Paid APIs:**
- Use API provider's usage dashboard
- Set up programmatic checks (daily/weekly usage scripts)
- Alert if usage exceeds thresholds

---

## What I'm NOT Concerned With (For Now)

- Site uptime monitoring (assuming hosting handles it)
- Performance metrics (response times, latency)
- Traffic spikes causing downtime

These aren't critical at my current scale. Focus on cost protection and critical errors.

---

## Deployment Checklist

**Before Deploy:**
- [ ] Security audit completed (see `security_audit.md`)
- [ ] Environment variables set (API keys, DB URLs)
- [ ] Monitoring configured (cost, errors)
- [ ] Alerts configured (email notifications)
- [ ] Logging enabled (sanitized, no PII)
- [ ] Git reviewed for secrets (see BASE_RULES.md section D)

**After Deploy:**
- [ ] Verify monitoring is working (trigger test alert)
- [ ] Check logs for errors
- [ ] Monitor usage for first 24-48 hours

---

## Incident Response

**If Alert Fires:**
1. Check logs for root cause
2. Assess severity (user impact, cost impact)
3. Fix if obvious, else shut down problematic feature
4. Notify me if unsure

**If Costs Spike:**
1. Identify source (which API, which feature)
2. Rate limit or disable feature immediately
3. Investigate abuse or bug
4. Fix and re-enable with safeguards

---

## Deliverable

**Monitoring:** Platform dashboards configured, cost tracking enabled.

**Alerts:** Email notifications for thresholds I specify.

**Logging:** Production logs accessible, sanitized, useful for debugging.

**Runbook:** Document how to check logs, restart services, respond to alerts.