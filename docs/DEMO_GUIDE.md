# Video Demo Script & Walkthrough Guide
## ACME Org Employee Salary Management Platform

**Target Audience / Persona**: Global HR Director / People Operations Lead  
**Scale**: 10,000 Employees across 6 Global Locations & 8 Departments  
**Standard Currency**: Indian Rupee (INR - ₹)  
**System URL**: [http://localhost:3000](http://localhost:3000)  
**Backend API**: [http://localhost:3001](http://localhost:3001)  

---

### Part 1: Product Framing & Problem Context (0:00 - 0:45)
- **Narrative**: *"Welcome to the ACME Employee Salary Management platform. Previously, our People Operations team managed 10,000 employee salaries across multiple regional offices using disparate, fragile Excel spreadsheets. This caused severe lag, formula corruption, and made it nearly impossible to quickly answer leadership questions like our total payroll, departmental budget allocations, or whether we had gender pay disparities across job levels."*
- **The Solution**: *"We designed a centralized, high-performance web platform built with Ruby on Rails, PostgreSQL, and React, completely containerized with Docker. All compensation is standardized in Indian Rupees (₹), providing clean, unambiguous parity across our workforce."*

---

### Part 2: Executive Compensation Analytics Dashboard (0:45 - 2:00)
- **Action**: Navigate to `http://localhost:3000` (defaults to the *Executive Compensation Analytics* tab).
- **Key Talking Points**:
  1. **Global Summary KPIs**:
     - **Total Annual Payroll**: Point to the Total Payroll KPI widget (e.g., `₹2,204.18 Cr` / `₹22,04,18,11,000`). Show how instant database aggregation calculates this across all 10,000 employees.
     - **Median vs Mean Salary**: Explain that the median (`₹15.90 L`) is computed directly using PostgreSQL's `PERCENTILE_CONT(0.5)`, providing a realistic midpoint unaffected by top-earner skew compared to the arithmetic mean (`₹22.04 L`).
     - **Org Compa-Ratio**: Demonstrates organizational compensation health against market benchmarks (e.g., `100.6%`, squarely within the target 80%–120% band).
     - **Total Active Headcount**: Confirms `10,000` active employees and total variable bonus pool.
  2. **Payroll Allocation by Department**:
     - Hover over the interactive bar chart showing total salary expenditure across Engineering, Product, Sales, Support, Marketing, Finance, HR, and Legal.
     - Highlight that Engineering accounts for the largest share of payroll.
  3. **Compensation Band Health (Compa-Ratio Distribution)**:
     - Hover over the Donut Chart showing the breakdown:
       - Green: *Target Range (80% - 120%)* (~80% of employees)
       - Red: *Underpaid (< 80%)* (~10% of employees)
       - Purple: *Above Band (> 120%)* (~10% of employees)
  4. **Global Office Presence**:
     - Review headcount and spend across Bengaluru, Mumbai, Gurugram, Singapore, London, and San Francisco.
  5. **Pay Equity & Gender Gap Audit**:
     - Inspect the grouped bar chart comparing Male vs Female average compensation across Job Levels (L1 Junior Associate up to L6 Director/Executive).
     - Point out the overall pay parity indicator (e.g. `98.5%` parity) and note how the system highlights parity opportunities at senior levels.
  6. **Proactive Alerts & Outlier Detection**:
     - **Underpaid Top Performers**: Highlights high performers (Performance Rating ≥ 4) currently underpaid (< 85% compa-ratio) who represent immediate retention flight risks.
     - **Top Earners (99th Percentile)**: Identifies executive compensation outliers exceeding the P99 threshold.

---

### Part 3: Employee Directory & Real-Time Filtering (2:00 - 3:15)
- **Action**: Switch to the **Employee Directory (10,000 Records)** tab.
- **Key Talking Points**:
  1. **Sub-50ms Filtered Search**:
     - Type a name, title, or code in the search bar (e.g., `"Priya"`, `"Software Engineer"`, or `"EMP-001"`). Note the instant debounced response across 10,000 records.
  2. **Multi-Dimensional Dropdown Filtering**:
     - Filter by Department: Select `"Engineering"`.
     - Filter by Location: Select `"Bengaluru (India)"`.
     - Filter by Compa Band: Select `"Underpaid (< 80%)"`.
     - Show how the total count and paginated table update seamlessly without full page reload.
  3. **Server-Side Pagination & Column Sorting**:
     - Click the **Salary** header to sort descending and ascending.
     - Switch page size between 25, 50, and 100 rows per page.
     - Click next/previous page buttons.
  4. **CSV Export**:
     - Click **Export CSV** to demonstrate downloading the filtered compensation dataset for executive reporting.

---

### Part 4: Audited Salary Adjustment & Audit History (3:15 - 4:15)
- **Action**: Click on any employee row or click **Adjust** on an employee.
- **Key Talking Points**:
  1. **Comprehensive Compensation Profile**:
     - Modal opens displaying: Location, Department, Level, Performance Rating, Target Bonus %, Equity Shares, and Market Band (Min, Mid, Max).
     - Visual Compa-Ratio health indicator.
  2. **Audited Salary Revision**:
     - Enter a new salary in INR (e.g. change `₹ 22,00,000` to `₹ 25,00,000`).
     - Point out the **Live Adjustment Impact Preview**:
       - Automatically calculates the hike percentage (e.g., `+13.6%`).
       - Automatically recalculates the new Compa-Ratio (e.g., `108.7%`).
     - Select a mandatory Reason from the dropdown: `"Promotion"` or `"Merit Increase"`.
     - Add audit notes: `"Promoted to Staff Engineer after H2 performance cycle"`.
     - Click **Save Salary Adjustment**.
  3. **Immediate Reflection & Audit Trail**:
     - Notice the success notification and the new entry instantly added to the **Salary Adjustment History & Audit Trail** timeline.
     - Close the modal: note that the employee table and global KPI metrics update automatically to reflect the new compensation.

---

### Part 5: Engineering Rigor & Conclusion (4:15 - 4:45)
- **Recap**:
  - 10,000 realistic employees seeded in **3.14 seconds** via bulk `insert_all`.
  - Database-native SQL aggregations (`PERCENTILE_CONT`, `AVG`, `GROUP BY`) executing in **< 15ms**.
  - Fully containerized with Docker (`docker compose up`), automated test suite with **100% pass rate** (18 tests, 72 assertions).
  - Modern, custom, zero-bloat CSS design system adhering strictly to user guidelines (no Tailwind, standard INR currency).
