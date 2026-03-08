# Database Design Skill

Load this when: designing schemas, writing migrations, optimizing queries, structuring data.

---

## Default Stack

**Database:** Supabase (Postgres)
**Patterns:** Relational, normalized (within reason)

---

## Schema Design Principles

**Normalization:** Normalize to avoid redundancy, but don't over-normalize. If a JOIN hurts performance and denormalization makes sense, do it.

**Foreign Keys:** Always use them. Enforce referential integrity at DB level.

**Indexes:** Index columns used in WHERE, JOIN, ORDER BY. Don't over-index (slows writes).

**Naming:** Clear, consistent. `user_id` not `uid`. `created_at` not `ctime`. Pluralize table names (`users`, `orders`).

**Timestamps:** Every table gets `created_at`, `updated_at` (auto-managed).

**Soft Deletes:** Consider `deleted_at` instead of hard deletes for important data.

---

## Data Types

**IDs:** UUID or auto-increment int (prefer UUID for distributed systems).

**Timestamps:** `timestamptz` (timezone-aware).

**Money:** `numeric` or `decimal`, never float.

**Text:** `text` unless you need length constraints, then `varchar(n)`.

**JSON:** Use `jsonb` for flexible/nested data. Don't abuse it—use tables when structure is clear.

---

## Migrations

**Version Control:** Every schema change is a migration. Never modify old migrations.

**Reversibility:** Write both `up` and `down` migrations when possible.

**Data Migrations:** Separate schema changes from data changes. Run in order.

**Testing:** Test migrations on copy of prod data before deploying.

---

## Query Optimization

**N+1 Queries:** Use JOINs or batch fetches. Don't loop and query.

**SELECT *:** Avoid. Specify columns you need.

**Indexes:** If query is slow, check EXPLAIN. Add indexes to filter/join columns.

**Pagination:** Use `LIMIT`/`OFFSET` or cursor-based pagination for large datasets.

---

## Supabase-Specific

**Row-Level Security (RLS):** Enable on tables with user data. Define policies for access control.

**Real-time:** Use Supabase real-time subscriptions for live data (chat, notifications).

**Storage:** Use Supabase Storage for files. Store file URLs in DB, not file content.

**Functions:** Use Postgres functions for complex logic that benefits from running in DB.

---

## Security

**Validate at DB Level:** Use constraints (NOT NULL, UNIQUE, CHECK).

**No Raw SQL from User Input:** Always parameterize queries. Use ORM or prepared statements.

**Encryption:** Sensitive fields (SSN, credit cards) should be encrypted at application layer before DB write.

**Access Control:** Supabase RLS policies enforce who can read/write. Don't rely solely on application logic.

---

## Deliverable

**Schema:** Clear, normalized (within reason), indexed appropriately.

**Migrations:** Versioned, tested, reversible.

**Queries:** Efficient, avoid N+1, use indexes.