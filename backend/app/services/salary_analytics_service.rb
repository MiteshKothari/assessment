# High-Performance SQL Aggregation Engine for Salary Analytics
class SalaryAnalyticsService
  def self.summary
    sql = <<~SQL
      SELECT
        COUNT(*) AS total_headcount,
        COALESCE(SUM(salary), 0) AS total_payroll,
        COALESCE(AVG(salary), 0) AS mean_salary,
        COALESCE(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary), 0) AS median_salary,
        COALESCE(MIN(salary), 0) AS min_salary,
        COALESCE(MAX(salary), 0) AS max_salary,
        COALESCE(AVG(compa_ratio), 0) AS avg_compa_ratio,
        COALESCE(SUM(salary * (bonus_percentage / 100.0)), 0) AS total_bonus_pool
      FROM employees;
    SQL

    row = ActiveRecord::Base.connection.select_one(sql)
    gender_counts = Employee.group(:gender).count

    {
      total_headcount: row["total_headcount"].to_i,
      total_payroll: row["total_payroll"].to_f.round(2),
      mean_salary: row["mean_salary"].to_f.round(2),
      median_salary: row["median_salary"].to_f.round(2),
      min_salary: row["min_salary"].to_f.round(2),
      max_salary: row["max_salary"].to_f.round(2),
      avg_compa_ratio: row["avg_compa_ratio"].to_f.round(2),
      total_bonus_pool: row["total_bonus_pool"].to_f.round(2),
      gender_distribution: gender_counts
    }
  end

  def self.department_breakdown
    sql = <<~SQL
      SELECT
        d.id AS department_id,
        d.name,
        d.code,
        d.budget_inr,
        COUNT(e.id) AS headcount,
        COALESCE(SUM(e.salary), 0) AS total_salary,
        COALESCE(AVG(e.salary), 0) AS avg_salary,
        COALESCE(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary), 0) AS median_salary,
        COALESCE(AVG(e.compa_ratio), 0) AS avg_compa_ratio
      FROM departments d
      LEFT JOIN employees e ON e.department_id = d.id
      GROUP BY d.id, d.name, d.code, d.budget_inr
      ORDER BY total_salary DESC;
    SQL

    results = ActiveRecord::Base.connection.select_all(sql)
    results.map do |r|
      total_sal = r["total_salary"].to_f
      budget = r["budget_inr"].to_f
      utilization = budget.positive? ? ((total_sal / budget) * 100).round(2) : 0.0

      {
        department_id: r["department_id"].to_i,
        name: r["name"],
        code: r["code"],
        headcount: r["headcount"].to_i,
        total_salary: total_sal.round(2),
        avg_salary: r["avg_salary"].to_f.round(2),
        median_salary: r["median_salary"].to_f.round(2),
        avg_compa_ratio: r["avg_compa_ratio"].to_f.round(2),
        budget_inr: budget.round(2),
        budget_utilization_pct: utilization
      }
    end
  end

  def self.location_breakdown
    sql = <<~SQL
      SELECT
        l.id AS location_id,
        l.city,
        l.country,
        l.office_name,
        COUNT(e.id) AS headcount,
        COALESCE(SUM(e.salary), 0) AS total_salary,
        COALESCE(AVG(e.salary), 0) AS avg_salary,
        COALESCE(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary), 0) AS median_salary
      FROM locations l
      LEFT JOIN employees e ON e.location_id = l.id
      GROUP BY l.id, l.city, l.country, l.office_name
      ORDER BY headcount DESC;
    SQL

    results = ActiveRecord::Base.connection.select_all(sql)
    results.map do |r|
      {
        location_id: r["location_id"].to_i,
        city: r["city"],
        country: r["country"],
        office_name: r["office_name"],
        headcount: r["headcount"].to_i,
        total_salary: r["total_salary"].to_f.round(2),
        avg_salary: r["avg_salary"].to_f.round(2),
        median_salary: r["median_salary"].to_f.round(2)
      }
    end
  end

  def self.pay_equity
    sql = <<~SQL
      SELECT
        jl.id AS job_level_id,
        jl.name AS level_name,
        jl.grade,
        jl.mid_salary_inr,
        e.gender,
        COUNT(e.id) AS count,
        COALESCE(AVG(e.salary), 0) AS avg_salary,
        COALESCE(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary), 0) AS median_salary
      FROM job_levels jl
      JOIN employees e ON e.job_level_id = jl.id
      GROUP BY jl.id, jl.name, jl.grade, jl.mid_salary_inr, e.gender
      ORDER BY jl.grade ASC, e.gender ASC;
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql)
    
    # Group by level
    levels_data = {}
    rows.each do |row|
      lvl_id = row["job_level_id"].to_i
      levels_data[lvl_id] ||= {
        level_id: lvl_id,
        level_name: row["level_name"],
        grade: row["grade"].to_i,
        mid_salary_inr: row["mid_salary_inr"].to_f,
        genders: {}
      }

      levels_data[lvl_id][:genders][row["gender"]] = {
        count: row["count"].to_i,
        avg_salary: row["avg_salary"].to_f.round(2),
        median_salary: row["median_salary"].to_f.round(2)
      }
    end

    # Calculate equity ratios per level
    comparison = levels_data.values.map do |lvl|
      male_data = lvl[:genders]["Male"] || { count: 0, avg_salary: 0.0, median_salary: 0.0 }
      female_data = lvl[:genders]["Female"] || { count: 0, avg_salary: 0.0, median_salary: 0.0 }
      nb_data = lvl[:genders]["Non-Binary"] || { count: 0, avg_salary: 0.0, median_salary: 0.0 }

      pay_ratio = if male_data[:avg_salary].positive?
                    ((female_data[:avg_salary] / male_data[:avg_salary]) * 100).round(2)
                  else
                    100.0
                  end

      gap_percentage = (100.0 - pay_ratio).round(2)

      {
        level_id: lvl[:level_id],
        level_name: lvl[:level_name],
        grade: lvl[:grade],
        mid_salary_inr: lvl[:mid_salary_inr],
        male: male_data,
        female: female_data,
        non_binary: nb_data,
        female_to_male_ratio: pay_ratio,
        pay_gap_pct: gap_percentage
      }
    end

    # Global gender pay gap
    overall_sql = <<~SQL
      SELECT
        gender,
        COUNT(*) AS count,
        AVG(salary) AS avg_salary,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
      FROM employees
      GROUP BY gender;
    SQL
    overall_rows = ActiveRecord::Base.connection.select_all(overall_sql).index_by { |r| r["gender"] }
    
    male_avg = overall_rows.dig("Male", "avg_salary").to_f
    female_avg = overall_rows.dig("Female", "avg_salary").to_f
    overall_ratio = male_avg.positive? ? ((female_avg / male_avg) * 100).round(2) : 100.0

    {
      levels: comparison,
      overall: {
        male: overall_rows["Male"] ? { count: overall_rows["Male"]["count"].to_i, avg_salary: male_avg.round(2), median_salary: overall_rows["Male"]["median_salary"].to_f.round(2) } : nil,
        female: overall_rows["Female"] ? { count: overall_rows["Female"]["count"].to_i, avg_salary: female_avg.round(2), median_salary: overall_rows["Female"]["median_salary"].to_f.round(2) } : nil,
        female_to_male_ratio: overall_ratio,
        overall_pay_gap_pct: (100.0 - overall_ratio).round(2)
      }
    }
  end

  def self.compa_distribution
    sql = <<~SQL
      SELECT
        CASE
          WHEN compa_ratio < 80.0 THEN 'Underpaid (< 80%)'
          WHEN compa_ratio <= 120.0 THEN 'Target Range (80% - 120%)'
          ELSE 'Above Band (> 120%)'
        END AS compa_bracket,
        COUNT(*) AS count,
        AVG(salary) AS avg_salary
      FROM employees
      GROUP BY 1
      ORDER BY MIN(compa_ratio) ASC;
    SQL

    results = ActiveRecord::Base.connection.select_all(sql)
    total = Employee.count

    results.map do |r|
      cnt = r["count"].to_i
      pct = total.positive? ? ((cnt.to_f / total) * 100).round(2) : 0.0
      {
        bracket: r["compa_bracket"],
        count: cnt,
        percentage: pct,
        avg_salary: r["avg_salary"].to_f.round(2)
      }
    end
  end

  def self.outliers
    # 99th percentile threshold
    p99_sql = "SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY salary) AS p99 FROM employees;"
    p99_salary = ActiveRecord::Base.connection.select_value(p99_sql).to_f

    top_earners = Employee.includes(:department, :job_level, :location)
                          .where("salary >= ?", p99_salary)
                          .order(salary: :desc)
                          .limit(15)

    # Underpaid top performers: performance rating >= 4 but compa_ratio < 85
    underpaid_stars = Employee.includes(:department, :job_level, :location)
                              .where("performance_rating >= 4 AND compa_ratio < 85")
                              .order(compa_ratio: :asc)
                              .limit(15)

    {
      top_earners_threshold: p99_salary.round(2),
      top_earners: top_earners.map { |e| serialize_employee_mini(e) },
      underpaid_stars: underpaid_stars.map { |e| serialize_employee_mini(e) }
    }
  end

  def self.serialize_employee_mini(e)
    {
      id: e.id,
      employee_code: e.employee_code,
      name: e.full_name,
      job_title: e.job_title,
      department: e.department.name,
      location: e.location.city,
      job_level: e.job_level.name,
      salary: e.salary.to_f,
      compa_ratio: e.compa_ratio.to_f,
      performance_rating: e.performance_rating
    }
  end
end
