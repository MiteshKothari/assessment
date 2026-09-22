require "test_helper"

class JobLevelTest < ActiveSupport::TestCase
  test "validates salary band ordering" do
    invalid_level = JobLevel.new(
      name: "Broken Level",
      grade: 99,
      min_salary_inr: 2_000_000.0,
      mid_salary_inr: 1_500_000.0, # Mid is lower than min!
      max_salary_inr: 3_000_000.0
    )

    assert_not invalid_level.valid?
    assert_includes invalid_level.errors[:min_salary_inr], "must be less than midpoint salary"
  end
end
