# ACME Org: Employee Salary Management & Compensation Platform

A high-performance, web-based salary management and compensation analytics platform built for the **HR Director (Sarah Chen)** of ACME Org to manage **10,000 employees** across global offices, eliminate spreadsheet bottlenecks, track audited salary revisions, and answer strategic questions about organizational pay equity and compensation health in **Indian Rupees (INR - ₹)**.

---

## 1. Key Features

- **Executive Compensation Dashboard ("How the Org Pays People")**:
  - **Global KPIs**: Real-time Total Annual Payroll (₹), Median Salary (P50 database percentile), Mean Salary, Org Average Compa-Ratio, and Headcount.
  - **Departmental Payroll Allocation**: Visual breakdown of total compensation expenditure and headcount across 8 departments.
  - **Pay Equity & Gender Gap Audit**: Level-by-level (L1 to L6) and overall comparative analysis of male vs. female compensation with pay parity ratios.
  - **Compa-Ratio Band Health**: Visual distribution of employees categorized into Underpaid (< 80%), Target Band (80% - 120%), and Above Band (> 120%).
  - **Proactive Outlier Detection**: Flags retention flight risks (underpaid high performers with rating ≥ 4) and executive top earners (99th percentile).
- **High-Performance Employee Directory (10,000 Records)**:
  - Sub-30ms indexed search across name, email, employee code, and job title.
  - Multi-dimensional filters: Department, Office Location, Job Level, Compa-Ratio Status, and Performance Rating.
  - Server-side pagination and multi-column sorting.
  - Direct CSV Export of filtered employee records.
- **Audited Salary Adjustments**:
  - Detailed employee profile view (Base Salary in INR, Bonus %, Equity, Market Band Min/Mid/Max).
  - Audited salary adjustments requiring revision reason (Merit, Promotion, Market Correction, Retention, Transfer) and optional notes.
  - Live preview of salary hike % and new compa-ratio before saving.
  - Immutable historical audit timeline displaying past adjustments.

---

## 2. Technical Stack & Engineering Highlights

- **Backend**: Ruby on Rails 7.2 (API mode) on `ruby:3.3-slim`.
- **Database**: PostgreSQL 16 (`postgres:16-alpine`) with B-tree and composite indexing.
- **Frontend**: React 18 with Vite, Recharts, and Lucide Icons.
- **Styling Architecture**: Custom bespoke CSS design system (CSS custom properties, flex/grid, zero Tailwind CSS build overhead).
- **Currency**: Standardized in **INR (₹)** across schema, database, seed generator, and UI.
- **Seeding Performance**: Bulk inserts (`insert_all` in chunks of 2,000) seed **10,000 realistic employees** and **3,000 salary audit records** in **~3.14 seconds**.
- **Containerization**: Fully orchestrated via `docker-compose.yml`.

---

## 3. Quickstart & Deployment

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) & Docker Compose installed.

### Launch Application
From the project root (`E:\Assessment`):
```bash
docker compose up -d
```

Once running:
- **Frontend Application**: [http://localhost:3000](http://localhost:3000)
- **Backend Rails API**: [http://localhost:3001](http://localhost:3001)
- **API Health Check**: [http://localhost:3001/up](http://localhost:3001/up)
- **API Summary**: [http://localhost:3001/api/v1/analytics/summary](http://localhost:3001/api/v1/analytics/summary)

---

## 4. Running the Automated Test Suite

The backend includes a comprehensive suite of model, service, and API integration tests covering validations, compa-ratio calculations, audited adjustments, SQL aggregations, and endpoint filters:

```bash
docker compose run --rm backend bundle exec rails test
```

**Results**:
```
Finished in ~3.2s
18 runs, 72 assertions, 0 failures, 0 errors, 0 skips (100% Pass Rate)
```

---

## 5. Re-Seeding the 10,000 Employee Database

To reset and re-seed 10,000 employees with fresh distributions:
```bash
docker compose run --rm backend bundle exec rails db:seed
```

---

## 6. Project Artifacts & Documentation

Detailed engineering documentation and thought process artifacts are located in `/docs`:
- [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md): 1-Page Product Requirements Document (PRD) detailing persona, scope, metrics, and out-of-scope rationale.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): System architecture, ERD, PostgreSQL schema, and indexing strategy.
- [docs/PERFORMANCE.md](docs/PERFORMANCE.md): Performance analysis and benchmarks for handling 10,000 records.
- [docs/TRADEOFFS.md](docs/TRADEOFFS.md): Architectural decisions and trade-offs.
- [docs/AI_PROMPTS.md](docs/AI_PROMPTS.md): Strategic AI usage log, prompt design, and human-in-the-loop review.
- [docs/DEMO_GUIDE.md](docs/DEMO_GUIDE.md): Script and walkthrough for the HR Manager video demo.
