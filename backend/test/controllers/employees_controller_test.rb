require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  def setup
    create_reference_data!
    @emp = Employee.create!(
      employee_code: "EMP-001",
      first_name: "Anita",
      last_name: "Desai",
      email: "anita@acme-corp.com",
      gender: "Female",
      department: @dept,
      location: @loc,
      job_level: @level,
      job_title: "Lead Architect",
      employment_type: "Full-Time",
      hire_date: Date.current - 2.years,
      salary: 2_400_000.0,
      bonus_percentage: 12.0,
      equity_shares: 400,
      performance_rating: 5
    )
  end

  test "GET /api/v1/employees returns paginated json list" do
    get "/api/v1/employees"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["employees"].length
    assert_equal "EMP-001", json["employees"][0]["employee_code"]
    assert_equal 1, json["meta"]["total_count"]
    assert_equal 1, json["meta"]["current_page"]
  end

  test "GET /api/v1/employees/:id returns detailed record with salary history" do
    get "/api/v1/employees/#{@emp.id}"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "EMP-001", json["employee"]["employee_code"]
    assert_equal 2_400_000.0, json["employee"]["salary"]
    assert_includes json["employee"], "salary_histories"
  end

  test "POST /api/v1/employees/:id/adjust_salary performs valid salary adjustment" do
    post "/api/v1/employees/#{@emp.id}/adjust_salary", params: {
      new_salary: 2_700_000.0,
      change_reason: "Promotion",
      notes: "Promoted to Principal Architect"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Salary successfully updated", json["message"]
    assert_equal 2_700_000.0, json["employee"]["salary"]
  end

  test "GET /api/v1/employees/export returns CSV file" do
    get "/api/v1/employees/export"
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
    assert_includes response.body, "Employee Code,Full Name"
    assert_includes response.body, "EMP-001"
  end
end
