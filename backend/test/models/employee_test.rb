require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  def setup
    create_reference_data!
    @employee = Employee.new(
      employee_code: "EMP-TEST-01",
      first_name: "Rahul",
      last_name: "Sharma",
      email: "rahul.sharma@acme-corp.com",
      gender: "Male",
      department: @dept,
      location: @loc,
      job_level: @level,
      job_title: "Senior Backend Developer",
      employment_type: "Full-Time",
      hire_date: Date.current - 1.year,
      salary: 2_200_000.0,
      bonus_percentage: 15.0,
      equity_shares: 500,
      performance_rating: 4
    )
  end

  test "should be valid with complete attributes" do
    assert @employee.valid?
    assert_equal 100.0, @employee.compa_ratio
  end

  test "requires unique employee code" do
    @employee.save!
    duplicate = @employee.dup
    duplicate.email = "other@acme-corp.com"
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:employee_code], "has already been taken"
  end

  test "requires valid email format" do
    @employee.email = "invalid-email"
    assert_not @employee.valid?
    assert_includes @employee.errors[:email], "is invalid"
  end

  test "adjust_salary! updates salary and records audit history" do
    @employee.save!
    old_salary = @employee.salary

    assert_difference "SalaryHistory.count", 1 do
      @employee.adjust_salary!(
        new_salary: 2_500_000.0,
        change_reason: "Merit Increase",
        notes: "Exceeded annual performance OKRs"
      )
    end

    @employee.reload
    assert_equal 2_500_000.0, @employee.salary.to_f
    assert_in_delta 113.64, @employee.compa_ratio.to_f, 0.05

    history = @employee.salary_histories.first
    assert_equal old_salary.to_f, history.previous_salary.to_f
    assert_equal 2_500_000.0, history.new_salary.to_f
    assert_equal "Merit Increase", history.change_reason
    assert_in_delta 13.64, history.change_percentage.to_f, 0.05
  end

  test "adjust_salary! raises on invalid parameters" do
    @employee.save!
    assert_raises(ArgumentError) do
      @employee.adjust_salary!(new_salary: -500, change_reason: "Merit Increase")
    end
    assert_raises(ArgumentError) do
      @employee.adjust_salary!(new_salary: 2_500_000, change_reason: "")
    end
  end
end
