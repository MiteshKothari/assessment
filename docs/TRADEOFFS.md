# Architectural & Engineering Trade-offs

## 1. Relational Database (PostgreSQL) vs Document Store (MongoDB)
- **Decision**: PostgreSQL 16.
- **Trade-off**: PostgreSQL requires upfront migrations and rigid schema definitions compared to schemaless document stores.
- **Rationale**: Salary and compensation data is strictly relational and requires ACID transaction guarantees (especially when adjusting salaries and recording audit histories). Furthermore, PostgreSQL's statistical aggregation functions (e.g. `PERCENTILE_CONT`, `FILTER (WHERE ...)`) allow computing accurate median compensation and gender pay gap metrics directly inside the database engine.

---

## 2. Server-Side Pagination vs Client-Side Virtualized Table
- **Decision**: Server-side pagination with database limit/offset.
- **Trade-off**: The browser requires network roundtrips to fetch new pages rather than having all 10,000 rows in memory for immediate in-browser filtering.
- **Rationale**: Transferring 10,000 full records (~15MB JSON) over mobile or slow networks impairs initial page load and causes heavy JavaScript memory consumption. Server-side pagination ensures every page load transfers only ~20KB and renders in < 50ms consistently.

---

## 3. Standardized INR (₹) vs Multi-Currency Live Conversion
- **Decision**: Unified baseline currency in INR (₹) across the organization.
- **Trade-off**: Does not show localized foreign currencies in real-time tickers.
- **Rationale**: For an organization managing compensation across teams, corporate leadership sets budgets and evaluates equitable pay based on a consistent corporate baseline currency. Fluctuating live exchange rates introduce daily artificial variance into pay equity comparisons.

---

## 4. Modern Bespoke CSS Architecture vs Utility Frameworks (Tailwind)
- **Decision**: Bespoke CSS custom properties (variables), modern CSS Grid, and Flexbox modules.
- **Trade-off**: Requires writing structured stylesheet classes rather than inline utility classes.
- **Rationale**: Complies directly with project constraints, produces zero CSS runtime/compiler bloat, provides clear semantic classes (`.stat-card`, `.data-table`, `.modal-overlay`), and ensures full control over responsive layouts.

---

## 5. Precomputed Compa-Ratio Column vs Dynamic Runtime Calculation
- **Decision**: Store `compa_ratio` directly on the `employees` table and update it upon salary changes.
- **Trade-off**: Requires keeping `compa_ratio` in sync when salary or job band changes.
- **Rationale**: Allows indexing on `compa_ratio` (`idx_employees_compa_ratio`), enabling instant sub-10ms filtering for "underpaid (< 80%)" or "overpaid (> 120%)" employees across 10,000 records without performing real-time cross-table joins during every search.
