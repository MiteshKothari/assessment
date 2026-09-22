class SalaryHistory < ApplicationRecord
  belongs_to :employee

  REASONS = [
    "Merit Increase",
    "Promotion",
    "Market Adjustment",
    "Retention",
    "Internal Transfer",
    "Annual Review",
    "Probation Completion"
  ].freeze

  validates :previous_salary, numericality: { greater_than_or_equal_to: 0 }
  validates :new_salary, numericality: { greater_than: 0 }
  validates :change_percentage, numericality: true
  validates :change_reason, presence: true, inclusion: { in: REASONS }
  validates :effective_date, presence: true
end
