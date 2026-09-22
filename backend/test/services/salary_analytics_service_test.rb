require "test_helper"

class SalaryAnalyticsServiceTest < ActiveSupport::TestCase
  def setup
    create_reference_data!
    # Create two employees
    Employee.create!(
      employee_code: "EMP-MALE",
      first_name: "Amit",
      last_name: "Kumar",
      email: "amit@acme-corp.com",
      gender: "Male",
      department: @dept,
      location: @loc,
      job_level: @level,
      job_title: "Software Engineer",
      employment_type: "Full-Time",
      hire_date: Date.current,
      salary: 2_000_000.0,
      bonus_percentage: 10.0,
      equity_shares: 100,
      performance_rating: 3
    )

    Employee.create!(
      employee_code: "EMP-FEMALE",
      first_name: "Priya",
      last_name: "Sharma",
      email: "priya@acme-corp.com",
      gender: "Female",
      department: @dept,
      location: @loc,
      job_level: @level,
      job_title: "Software Engineer",
      employment_type: "Full-Time",
      hire_date: Date.current,
      salary: 2_200_000.0,
      bonus_percentage: 10.0,
      equity_shares: 100,
      performance_rating: 4
    )
  end

  test "summary calculates exact headcount, payroll, mean, and median" do
    summary = SalaryAnalyticsService.summary
    assert_equal 2, summary[:total_headcount]
    assert_equal 4_200_000.0, summary[:total_payroll]
    assert_equal 2_100_000.0, summary[:mean_salary]
    assert_equal 2_100_000.0, summary[:median_salary]
  end

  test "department_breakdown returns accurate spending and utilization" do
    departments = SalaryAnalyticsService.department_breakdown
    eng = departments.find { |d| d[:name] == "Engineering" }

    assert_not_nil eng
    assert_equal 2, eng[:headcount]
    assert_equal 4_200_000.0, eng[:total_salary]
    assert_equal 2_100_000.0, eng[:avg_salary]
  end

  test "pay_equity computes gender pay ratio" do
    equity = SalaryAnalyticsService.pay_equity
    level_eq = equity[:levels].find { |l| l[:level_id] == @level.id }

    assert_not_nil level_eq
    assert_equal 2_000_000.0, level_eq[:male][:avg_salary]
    assert_equal 2_200_000.0, level_eq[:female][:avg_salary]
    # Ratio = (2,200,000 / 2,000,000) * 100 = 110.0%
    assert_equal 110.0, level_eq[:female_to_male_ratio]
  end
end
