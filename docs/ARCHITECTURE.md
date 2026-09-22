# Architecture & Technical Design Specification

## 1. System Architecture Overview

The ACME Salary Management Platform is architected as a decoupled, multi-container system containerized using Docker and orchestrated with Docker Compose:

```
+-------------------------------------------------------------------------+
|                              Client Browser                             |
|         React 18 + Modern Custom CSS + Recharts + Lucide Icons          |
+-------------------------------------------------------------------------+
                                    |
                                    | HTTP / JSON (Port 3000 -> 3001)
                                    v
+-------------------------------------------------------------------------+
|                           Ruby on Rails API                             |
|         (Ruby 3.3-slim, Rails 7.2 API Mode, Puma Application Server)    |
|                                                                         |
|  Controllers:            Services:                   Models:            |
|  - EmployeesController   - SalaryAnalyticsService    - Employee         |
|  - AnalyticsController                               - Department       |
|  - ReferenceDataController                           - Location         |
|                                                      - JobLevel         |
|                                                      - SalaryHistory    |
+-------------------------------------------------------------------------+
                                    |
                                    | PostgreSQL Protocol (Port 5432)
                                    v
+-------------------------------------------------------------------------+
|                              PostgreSQL 16                              |
|           Optimized B-tree & Composite Indexes, SQL Aggregations        |
|               (PERCENTILE_CONT, AVG, SUM, COUNT, GROUP BY)              |
+-------------------------------------------------------------------------+
```

---

## 2. Relational Database Schema & Data Model

### Entity-Relationship Diagram (ERD)

```
 [departments] (1) <---------- (N) [employees] (N) ----------> (1) [locations]
                                      |     |
                                      |     +--------> (1) [job_levels]
                                      |
                                      v (1)
                                     (N) [salary_histories]
```

### Table Definitions

#### `departments`
- `id`: BIGSERIAL PRIMARY KEY
- `name`: VARCHAR(100) NOT NULL UNIQUE
- `code`: VARCHAR(20) NOT NULL UNIQUE
- `budget_inr`: NUMERIC(15, 2) NOT NULL DEFAULT 0.00
- `created_at`, `updated_at`: TIMESTAMP

#### `locations`
- `id`: BIGSERIAL PRIMARY KEY
- `city`: VARCHAR(100) NOT NULL
- `country`: VARCHAR(100) NOT NULL
- `office_name`: VARCHAR(150) NOT NULL
- `created_at`, `updated_at`: TIMESTAMP

#### `job_levels`
- `id`: BIGSERIAL PRIMARY KEY
- `name`: VARCHAR(50) NOT NULL UNIQUE (e.g., "L1 - Junior", "L2 - Associate", "L3 - Senior", "L4 - Staff", "L5 - Principal", "L6 - Director")
- `grade`: INTEGER NOT NULL UNIQUE (1 to 6)
- `min_salary_inr`: NUMERIC(15, 2) NOT NULL
- `mid_salary_inr`: NUMERIC(15, 2) NOT NULL
- `max_salary_inr`: NUMERIC(15, 2) NOT NULL
- `created_at`, `updated_at`: TIMESTAMP

#### `employees` (10,000 Records)
- `id`: BIGSERIAL PRIMARY KEY
- `employee_code`: VARCHAR(20) NOT NULL UNIQUE (e.g., "EMP-00001")
- `first_name`: VARCHAR(100) NOT NULL
- `last_name`: VARCHAR(100) NOT NULL
- `email`: VARCHAR(150) NOT NULL UNIQUE
- `gender`: VARCHAR(20) NOT NULL (Male, Female, Non-Binary)
- `department_id`: BIGINT NOT NULL REFERENCES departments(id)
- `location_id`: BIGINT NOT NULL REFERENCES locations(id)
- `job_level_id`: BIGINT NOT NULL REFERENCES job_levels(id)
- `job_title`: VARCHAR(150) NOT NULL
- `employment_type`: VARCHAR(50) NOT NULL DEFAULT 'Full-Time' (Full-Time, Contract, Part-Time)
- `hire_date`: DATE NOT NULL
- `salary`: NUMERIC(15, 2) NOT NULL
- `bonus_percentage`: NUMERIC(5, 2) NOT NULL DEFAULT 10.00
- `equity_shares`: INTEGER NOT NULL DEFAULT 0
- `performance_rating`: INTEGER NOT NULL DEFAULT 3 (1 to 5)
- `compa_ratio`: NUMERIC(6, 2) NOT NULL (Computed as `(salary / job_level.mid_salary_inr) * 100`)
- `created_at`, `updated_at`: TIMESTAMP

#### `salary_histories` (Audit Log)
- `id`: BIGSERIAL PRIMARY KEY
- `employee_id`: BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE
- `previous_salary`: NUMERIC(15, 2) NOT NULL
- `new_salary`: NUMERIC(15, 2) NOT NULL
- `change_percentage`: NUMERIC(6, 2) NOT NULL
- `change_reason`: VARCHAR(100) NOT NULL (Merit Increase, Promotion, Market Adjustment, Retention, Transfer)
- `effective_date`: DATE NOT NULL
- `notes`: TEXT
- `created_at`: TIMESTAMP

---

## 3. Indexing Strategy for 10,000+ Records

To guarantee sub-50ms response times for arbitrary filters and pagination:

```sql
-- Single column lookups & joins
CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_location_id ON employees(location_id);
CREATE INDEX idx_employees_job_level_id ON employees(job_level_id);
CREATE INDEX idx_employees_gender ON employees(gender);
CREATE INDEX idx_employees_performance_rating ON employees(performance_rating);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_compa_ratio ON employees(compa_ratio);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);

-- Composite indexes for frequent analytical aggregations & filtered queries
CREATE INDEX idx_employees_dept_level ON employees(department_id, job_level_id);
CREATE INDEX idx_employees_level_gender ON employees(job_level_id, gender);
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);

-- Salary history lookup
CREATE INDEX idx_salary_histories_employee_id ON salary_histories(employee_id);
```

---

## 4. API Endpoints Specification

### 4.1. Employees
- `GET /api/v1/employees`
  - Query params: `search`, `department_id`, `location_id`, `job_level_id`, `performance_rating`, `compa_status` (underpaid/in_band/overpaid), `sort_by`, `sort_order`, `page`, `per_page`
  - Returns: `{ employees: [...], meta: { current_page, total_pages, total_count, per_page } }`
- `GET /api/v1/employees/:id`
  - Returns detailed employee record including complete `salary_histories`.
- `POST /api/v1/employees/:id/adjust_salary`
  - Body: `{ new_salary, change_reason, notes, effective_date }`
  - Creates an audit record in `salary_histories`, recalculates `compa_ratio`, updates `employees.salary`.
- `GET /api/v1/employees/export`
  - Returns filtered CSV payload.

### 4.2. Analytics ("How the Org Pays People")
- `GET /api/v1/analytics/summary`
  - Returns: Total Headcount, Total Annual Payroll (₹), Mean Salary, Median Salary (`PERCENTILE_CONT(0.5)`), Avg Compa-Ratio, Min Salary, Max Salary.
- `GET /api/v1/analytics/department_breakdown`
  - Returns: Headcount, Total Salary Spend, Avg Salary, Median Salary, and Budget per department.
- `GET /api/v1/analytics/location_breakdown`
  - Returns: Headcount and Total Spend by office location.
- `GET /api/v1/analytics/pay_equity`
  - Returns: Gender-wise Average Salary, Median Salary, and Ratio grouped by Job Level.
- `GET /api/v1/analytics/compa_distribution`
  - Returns: Headcount and Percentage in Underpaid (<80%), Target (80-120%), Above Band (>120%).
- `GET /api/v1/analytics/outliers`
  - Returns: Statistical top earners (>99th percentile) and underpaid top performers.

### 4.3. Reference Data
- `GET /api/v1/reference_data`
  - Returns departments, locations, and job_levels for filter dropdowns.
