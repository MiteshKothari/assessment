require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  def setup
    create_reference_data!
    Employee.create!(
      employee_code: "EMP-ANL-1",
      first_name: "Karan",
      last_name: "Mehra",
      email: "karan@acme-corp.com",
      gender: "Male",
      department: @dept,
      location: @loc,
      job_level: @level,
      job_title: "Tech Lead",
      employment_type: "Full-Time",
      hire_date: Date.current - 1.year,
      salary: 2_500_000.0,
      bonus_percentage: 15.0,
      equity_shares: 600,
      performance_rating: 4
    )
  end

  test "GET /api/v1/analytics/summary returns KPI metrics" do
    get "/api/v1/analytics/summary"
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json["total_headcount"]
    assert_equal 2_500_000.0, json["total_payroll"]
    assert_equal 2_500_000.0, json["mean_salary"]
    assert_equal 2_500_000.0, json["median_salary"]
  end

  test "GET /api/v1/analytics/department_breakdown returns departments data" do
    get "/api/v1/analytics/department_breakdown"
    assert_response :success
    json = JSON.parse(response.body)
    assert_operator json["departments"].length, :>=, 1
  end

  test "GET /api/v1/analytics/pay_equity returns pay equity comparisons" do
    get "/api/v1/analytics/pay_equity"
    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json, "levels"
    assert_includes json, "overall"
  end

  test "GET /api/v1/analytics/compa_distribution returns distribution brackets" do
    get "/api/v1/analytics/compa_distribution"
    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json, "distribution"
  end

  test "GET /api/v1/analytics/outliers returns p99 and underpaid stars" do
    get "/api/v1/analytics/outliers"
    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json, "top_earners"
    assert_includes json, "underpaid_stars"
  end
end
