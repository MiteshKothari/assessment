# Intentional AI Usage & Prompt Log

This document records the strategic use of AI assistance during the planning, architecture, implementation, and verification of the ACME Employee Salary Management platform.

---

## 1. Intentional AI Strategy

In this assessment, AI is used not as an unguided code generator, but as an **augmented engineering partner** with structured guardrails:
1. **Product Framing First**: Before touching code, AI was prompted to draft a rigorous 1-page PRD defining the HR Manager persona, pain points, core metrics, and what is deliberately left out.
2. **Architectural Review & Feedback Loop**: Incorporating direct user feedback (disallowing Tailwind CSS, standardizing on INR currency, and selecting PostgreSQL + Ruby on Rails Docker containerization).
3. **Performance-Driven Data Modeling**: Directing the AI to avoid memory-heavy anti-patterns (such as loading 10,000 ActiveRecord objects in memory) by designing database-native SQL aggregations (`PERCENTILE_CONT`, composite indexes, bulk `insert_all` seeds).
4. **Test-First Verification**: Using AI to generate fast, deterministic unit, model, and API tests.

---

## 2. Structured Prompts & AI Evolution

### Prompt Phase 1: Requirements & Persona Framing
- **Objective**: Establish the core product problem statement, user persona, and scope.
- **Key Prompt Guidance**:
  - *"Act as a Principal Product Architect. Formulate a 1-page PRD for an HR Manager managing 10,000 employees. Focus on answering strategic questions about organizational pay."*
  - *"Deliberately eliminate out-of-scope complexity (tax withholding, live forex, self-service) to focus on compensation visibility."*

### Prompt Phase 2: Performance & Scalability Modeling
- **Objective**: Engineer for 10,000 records with sub-50ms latency.
- **Key Prompt Guidance**:
  - *"Design the PostgreSQL schema and indexing strategy for 10,000 employees with instant multi-column search and statistical percentiles."*
  - *"Structure bulk seeding using `insert_all` in chunks of 2,000 to complete under 5 seconds."*

### Prompt Phase 3: Modern Custom CSS Design System
- **Objective**: Create a high-end, responsive, accessible UI without Tailwind CSS.
- **Key Prompt Guidance**:
  - *"Create a semantic CSS architecture using CSS custom properties (`--primary`, `--surface`, `--text-primary`), CSS Grid for KPI widgets, and responsive data table layouts."*

---

## 3. Human-in-the-Loop Engineering Validation
Every AI-generated file was reviewed for:
- Adherence to constraints (INR currency everywhere, no Tailwind, clean Docker integration).
- Type safety and SQL injection prevention (parameterized ActiveRecord queries).
- Clean separation of concerns (thin controllers, domain service objects, modular React components).
