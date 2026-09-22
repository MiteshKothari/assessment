class Department < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :budget_inr, numericality: { greater_than_or_equal_to: 0 }
end
