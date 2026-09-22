ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Helper to setup basic reference data
    def create_reference_data!
      @dept = Department.create!(name: "Engineering", code: "ENG", budget_inr: 50_000_000.0)
      @loc = Location.create!(city: "Bengaluru", country: "India", office_name: "Tech Park")
      @level = JobLevel.create!(
        name: "L3 - Senior Specialist",
        grade: 3,
        min_salary_inr: 1_600_000.0,
        mid_salary_inr: 2_200_000.0,
        max_salary_inr: 3_000_000.0
      )
    end
  end
end
