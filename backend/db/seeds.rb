# High-Performance 10,000 Employee Compensation Seed Script
require "benchmark"

puts "== Starting ACME 10,000 Employee Seed Generator =="

time_taken = Benchmark.realtime do
  ActiveRecord::Base.transaction do
    puts "Cleaning existing data..."
    SalaryHistory.delete_all
    Employee.delete_all
    JobLevel.delete_all
    Location.delete_all
    Department.delete_all
  end

  puts "Seeding Reference Data (Departments, Locations, Job Levels)..."

  departments_data = [
    { name: "Engineering", code: "ENG", budget_inr: 450_000_000.0 },
    { name: "Product & Design", code: "PRD", budget_inr: 140_000_000.0 },
    { name: "Sales & Business Dev", code: "SLS", budget_inr: 210_000_000.0 },
    { name: "Customer Operations", code: "OPS", budget_inr: 130_000_000.0 },
    { name: "Marketing", code: "MKT", budget_inr: 95_000_000.0 },
    { name: "Finance & Accounting", code: "FIN", budget_inr: 85_000_000.0 },
    { name: "People & Culture (HR)", code: "HR", budget_inr: 65_000_000.0 },
    { name: "Legal & Compliance", code: "LGL", budget_inr: 45_000_000.0 }
  ]
  departments = Department.create!(departments_data)
  dept_map = departments.index_by(&:name)

  locations_data = [
    { city: "Bengaluru", country: "India", office_name: "ACME Tech Park (Bellandur)" },
    { city: "Mumbai", country: "India", office_name: "ACME Financial Tower (BKC)" },
    { city: "Gurugram", country: "India", office_name: "ACME Cyber City Campus" },
    { city: "Singapore", country: "Singapore", office_name: "ACME APAC Regional Hub (Marina Bay)" },
    { city: "London", country: "United Kingdom", office_name: "ACME EMEA Office (Canary Wharf)" },
    { city: "San Francisco", country: "United States", office_name: "ACME Global HQ (Market St)" }
  ]
  locations = Location.create!(locations_data)
  location_ids = locations.map(&:id)

  job_levels_data = [
    { name: "L1 - Junior Associate", grade: 1, min_salary_inr: 450_000.0, mid_salary_inr: 700_000.0, max_salary_inr: 1_050_000.0 },
    { name: "L2 - Associate", grade: 2, min_salary_inr: 900_000.0, mid_salary_inr: 1_350_000.0, max_salary_inr: 1_850_000.0 },
    { name: "L3 - Senior Specialist", grade: 3, min_salary_inr: 1_650_000.0, mid_salary_inr: 2_350_000.0, max_salary_inr: 3_100_000.0 },
    { name: "L4 - Staff / Lead", grade: 4, min_salary_inr: 2_800_000.0, mid_salary_inr: 3_800_000.0, max_salary_inr: 4_900_000.0 },
    { name: "L5 - Principal / Manager", grade: 5, min_salary_inr: 4_600_000.0, mid_salary_inr: 6_200_000.0, max_salary_inr: 8_000_000.0 },
    { name: "L6 - Director / Executive", grade: 6, min_salary_inr: 7_800_000.0, mid_salary_inr: 10_500_000.0, max_salary_inr: 14_500_000.0 }
  ]
  job_levels = JobLevel.create!(job_levels_data)
  level_map = job_levels.index_by(&:grade)

  # Title dictionaries per department and level
  titles = {
    "ENG" => ["Software Engineer", "Backend Developer", "Frontend Developer", "DevOps Engineer", "Data Engineer", "QA Automation Engineer"],
    "PRD" => ["Product Manager", "UI/UX Designer", "Product Analyst", "Design Systems Lead"],
    "SLS" => ["Account Executive", "Sales Development Rep", "Enterprise Sales Director", "Customer Solutions Architect"],
    "OPS" => ["Operations Analyst", "Support Specialist", "Technical Support Engineer", "Operations Manager"],
    "MKT" => ["Growth Marketer", "Content Strategist", "SEO Specialist", "Brand Manager"],
    "FIN" => ["Financial Analyst", "Staff Accountant", "Payroll Specialist", "Finance Controller"],
    "HR"  => ["HR Business Partner", "Technical Recruiter", "People Operations Specialist", "Compensation Analyst"],
    "LGL" => ["Legal Counsel", "Contracts Specialist", "Compliance Officer"]
  }

  first_names_male = %w[Aarav Rohan Vikram Arjun Aditya Siddharth Rahul Ananya Amit Rajesh Kunal Karthik Varun Pranav Dev Nikhil Sanjay Manoj Deepak Harshil Ravi Suresh Alok Manish]
  first_names_female = %w[Priya Neha Shreya Pooja Divya Kavita Sneha Meera Anjali Ritu Deepa Tanvi Swati Riya Ishita Simran Nandini Shalini Suman Preeti Radhika Sunita Archana Shruti]
  first_names_nb = %w[Alex Jordan Morgan Sam Taylor Casey Avery Riley Cameron Jamie Kiran Robin Noor Quinn]
  last_names = %w[Sharma Verma Patel Mehta Iyer Nair Rao Gupta Joshi Sen Kulkarni Deshmukh Reddy Bhatia Singh Roy Banerjee Mukherjee Chatterjee Pillai Nambiar Agarwal Das Saxena Ahuja Kapoor]

  # Level distribution weights (Pyramid structure)
  # L1: 22%, L2: 32%, L3: 26%, L4: 13%, L5: 5%, L6: 2%
  level_weights = ([1] * 22) + ([2] * 32) + ([3] * 26) + ([4] * 13) + ([5] * 5) + ([6] * 2)

  # Department weights
  # ENG: 36%, SLS: 18%, OPS: 16%, PRD: 10%, MKT: 7%, FIN: 5%, HR: 5%, LGL: 3%
  dept_weights = (["ENG"] * 36) + (["SLS"] * 18) + (["OPS"] * 16) + (["PRD"] * 10) + (["MKT"] * 7) + (["FIN"] * 5) + (["HR"] * 5) + (["LGL"] * 3)

  puts "Generating 10,000 employee records in memory..."

  total_target = 10_000
  now = Time.current
  employees_to_insert = []
  
  (1..total_target).each do |i|
    # Employee code
    code = format("EMP-%05d", i)

    # Gender selection (~48% Male, ~48% Female, ~4% Non-Binary)
    gender_seed = rand(100)
    if gender_seed < 48
      gender = "Male"
      first_name = first_names_male.sample
    elsif gender_seed < 96
      gender = "Female"
      first_name = first_names_female.sample
    else
      gender = "Non-Binary"
      first_name = first_names_nb.sample
    end

    last_name = last_names.sample
    # Ensure unique email
    email = "#{first_name.downcase}.#{last_name.downcase}.#{i}@acme-corp.com"

    # Department
    dept_code = dept_weights.sample
    dept = departments.find { |d| d.code == dept_code }

    # Location (India locations 70%, Global 30%)
    location_id = rand(100) < 70 ? location_ids[0..2].sample : location_ids[3..5].sample

    # Level
    grade = level_weights.sample
    lvl = level_map[grade]

    # Title prefix based on level
    base_title = titles[dept_code].sample
    prefix = case grade
             when 1 then "Associate "
             when 2 then ""
             when 3 then "Senior "
             when 4 then "Staff / Lead "
             when 5 then "Principal "
             when 6 then "Director of "
             end
    job_title = "#{prefix}#{base_title}"

    # Hire date (between 5 years ago and 1 month ago)
    hire_date = Date.current - rand(30..1825).days

    # Salary: Gaussian-like distribution around mid_salary_inr
    # Compa-ratio typically between 0.80 and 1.25, with occasional outliers (0.72 - 1.35)
    variance_factor = (rand(-0.22..0.24) + rand(-0.06..0.06)).round(4)
    # Slight intentional variance for gender pay gap analysis to be discovered by HR
    if gender == "Female" && grade >= 4
      variance_factor -= 0.03
    end

    raw_salary = (lvl.mid_salary_inr * (1.0 + variance_factor)).round(-3) # round to nearest thousand
    salary = [raw_salary, lvl.min_salary_inr * 0.85].max # prevent unrealistically low values
    compa_ratio = ((salary / lvl.mid_salary_inr) * 100).round(2)

    # Performance rating: 1 (5%), 2 (15%), 3 (50%), 4 (22%), 5 (8%)
    p_seed = rand(100)
    rating = if p_seed < 5 then 1
             elsif p_seed < 20 then 2
             elsif p_seed < 70 then 3
             elsif p_seed < 92 then 4
             else 5
             end

    # Bonus % and Equity
    bonus_pct = [5, 10, 15, 20, 25, 30][grade - 1] + rand(-2..3)
    equity = grade >= 3 ? (grade * 150) + rand(50..400) : 0

    employees_to_insert << {
      employee_code: code,
      first_name: first_name,
      last_name: last_name,
      email: email,
      gender: gender,
      department_id: dept.id,
      location_id: location_id,
      job_level_id: lvl.id,
      job_title: job_title,
      employment_type: rand(100) < 94 ? "Full-Time" : (rand(100) < 60 ? "Contract" : "Part-Time"),
      hire_date: hire_date,
      salary: salary,
      bonus_percentage: bonus_pct,
      equity_shares: equity,
      performance_rating: rating,
      compa_ratio: compa_ratio,
      created_at: now,
      updated_at: now
    }
  end

  puts "Bulk inserting 10,000 employees into PostgreSQL in batches of 2,000..."
  employees_to_insert.each_slice(2_000).with_index do |batch, index|
    Employee.insert_all(batch)
    print "."
  end
  puts "\nCompleted 10,000 employee insertions!"

  # Generate historical salary records for employees with tenure > 1 year (~2,800 records)
  puts "Generating salary adjustment audit histories for tenured employees..."
  tenured_employees = Employee.where("hire_date < ?", Date.current - 1.year).limit(3_000).select(:id, :salary, :hire_date)
  
  reasons = SalaryHistory::REASONS
  histories_to_insert = []

  tenured_employees.each do |emp|
    # Past salary was lower
    hike_pct = [8.0, 10.5, 12.0, 15.0, 18.5, 22.0].sample
    prev_salary = (emp.salary / (1.0 + (hike_pct / 100.0))).round(-3)
    effective_date = emp.hire_date + rand(300..450).days

    histories_to_insert << {
      employee_id: emp.id,
      previous_salary: prev_salary,
      new_salary: emp.salary,
      change_percentage: hike_pct,
      change_reason: reasons.sample,
      effective_date: [effective_date, Date.current - 15.days].min,
      notes: "Annual cycle revision / leadership approval",
      created_at: now
    }
  end

  histories_to_insert.each_slice(1_000) do |batch|
    SalaryHistory.insert_all(batch)
  end
  puts "Inserted #{histories_to_insert.size} historical salary audit records!"
end

puts "\n== Seeding Completed Successfully in #{time_taken.round(2)}s =="
puts "Total Employees: #{Employee.count}"
puts "Total Salary Histories: #{SalaryHistory.count}"
puts "Total Payroll (INR): ₹#{Employee.sum(:salary).to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
