# Product Requirements Document (PRD)
## ACME Org: Employee Salary Management & Compensation Analytics Platform

**Document Version**: 1.0  
**Target Scale**: 10,000 Employees  
**Primary Currency**: Indian Rupee (INR - ₹)  
**Primary Persona**: Sarah Chen, HR Director / Compensation Lead  

---

### 1. Problem Statement & Context
Currently, ACME Org’s HR team manages salary data for 10,000 employees across multiple offices and departments via disconnected, error-prone Excel spreadsheets. This leads to critical operational bottlenecks:
1. **Spreadsheet Fragility & Lag**: Handling 10,000 multi-column employee compensation records in Excel causes crashes, broken formulas, and version control chaos.
2. **Inability to Answer Strategic Questions**: Leadership frequently asks questions that take days to compile:
   - *"What is our total annual payroll expenditure in INR?"*
   - *"Are we paying equitably across genders across job levels?"*
   - *"Which departments are exceeding market compensation bands?"*
   - *"Who are our top performers currently underpaid relative to their compa-ratio?"*
3. **Lack of Auditability**: Salary revisions, merit increases, and market corrections lack an immutable historical record with reasons and effective dates.

---

### 2. Objectives & Success Metrics
| Objective | Metric / Target |
|---|---|
| **Eliminate Spreadsheet Dependency** | 100% of employee salary records managed and updated through the web application. |
| **Instant Strategic Analytics** | HR Manager can answer organizational pay questions in < 2 seconds. |
| **High Query Performance at Scale** | Filtered search across 10,000 records returns in < 50ms. |
| **Audit Traceability** | 100% of salary adjustments logged with previous salary, new salary, change percentage, and reason. |

---

### 3. User Persona
- **Persona**: Sarah Chen
- **Role**: HR Director / Global People Operations Lead at ACME Org
- **Key Responsibilities**:
  - Oversees compensation planning, annual merit cycles, and pay equity compliance.
  - Reports payroll budgets, departmental distributions, and anomalies to the C-Suite and Board.
  - Ensures employees are compensated fairly according to market benchmark bands (Compa-Ratio: 80%–120%).

---

### 4. Scope & Functional Requirements

#### 4.1. Executive Compensation Analytics Dashboard ("How the Org Pays People")
1. **Global Summary KPIs**:
   - Total Headcount (10,000).
   - Total Annual Payroll in INR (₹).
   - Organization Average Salary & Median Salary in INR (calculated via database percentiles).
   - Organization Average Compa-Ratio.
2. **Departmental Compensation Breakdown**:
   - Total payroll expenditure by department (Engineering, Product, Sales, Marketing, HR, Finance, Legal, Support).
   - Average salary by department.
   - Headcount allocation by department.
3. **Location / Office Breakdown**:
   - Payroll spend and headcount distributed across regional offices (Bengaluru, Mumbai, Gurugram, Singapore, London, San Francisco).
4. **Pay Equity & Gender Disparity Analysis**:
   - Comparative average and median salaries between genders across job levels (L1 Junior to L6 Director).
   - Gender pay gap ratio indicator to highlight parity discrepancies.
5. **Compa-Ratio Distribution**:
   - Visual categorization of employees into:
     - Underpaid (< 80% of midpoint band)
     - Target Range (80% - 120% of midpoint band)
     - Above Band (> 120% of midpoint band)
6. **Compensation Outlier & Anomaly Detection**:
   - Highlight statistical high earners (> 99th percentile).
   - Flag high-performing employees (Rating 4 or 5) who are below band midpoint.

#### 4.2. High-Performance Employee Directory
1. **Search & Multi-Dimensional Filtering**:
   - Instant search across Employee Code, First Name, Last Name, Email, and Job Title.
   - Filter dropdowns: Department, Office Location, Job Level, Employment Type, Performance Rating.
2. **Server-Side Pagination & Sorting**:
   - 25, 50, or 100 records per page with database-level `OFFSET` and `LIMIT`.
   - Sort by any column (Salary, Name, Hire Date, Rating, Compa-Ratio).
3. **Formatted INR Compensation**:
   - Clean Indian currency notation (e.g., `₹ 24,50,000` / `₹ 24.5 L`).

#### 4.3. Salary Adjustment & Audit Logging
1. **Employee Detail Modal**:
   - View complete profile: Job Level, Department, Location, Base Salary (₹), Target Bonus %, Equity Shares, and Compa-Ratio.
2. **Adjust Salary Action**:
   - HR Manager can update Base Salary.
   - Mandatory reason selection: *Merit Increase*, *Promotion*, *Market Adjustment*, *Retention*, or *Internal Transfer*.
   - Optional notes field.
   - System automatically calculates new Compa-Ratio and appends a record to `salary_histories`.
3. **Salary History Timeline**:
   - Audit trail of past changes displayed chronologically.

#### 4.4. Reporting & Export
- Export filtered or full employee compensation dataset to CSV for executive reporting.

---

### 5. Deliberately Out of Scope & Rationale
| Feature | Rationale for Exclusion |
|---|---|
| **Currency Switching / Live Forex Tickers** | ACME Org standardizes corporate compensation in INR (₹). Live fluctuating currency toggles introduce volatility and confusion when comparing organizational parity. |
| **Tax Withholding & Bank Direct Deposit** | This is a *Compensation Strategy & Management* platform, not an operational payroll disbursement engine (e.g. ADP, Gusto). Statutory tax rules add local compliance overhead without improving HR strategic decision-making. |
| **Complex Multi-Tier Approval Workflows** | In v1, the HR Director holds direct administrative authority. Multi-step approvals create unnecessary process friction before baseline visibility is solved. |
| **Employee Self-Service Portal** | Providing 10,000 personal logins requires enterprise SSO (Okta/Azure AD) and localized privacy segregation, which is out of scope for the HR managerial tool. |
| **Tailwind CSS Utility Framework** | Excluded per project technical constraints. Built with a bespoke, maintainable modern CSS architecture. |
