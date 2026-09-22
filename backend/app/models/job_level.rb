class JobLevel < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :grade, presence: true, uniqueness: true, numericality: { only_integer: true }
  validates :min_salary_inr, numericality: { greater_than: 0 }
  validates :mid_salary_inr, numericality: { greater_than: 0 }
  validates :max_salary_inr, numericality: { greater_than: 0 }

  validate :salary_band_order

  private

  def salary_band_order
    return unless min_salary_inr && mid_salary_inr && max_salary_inr

    if min_salary_inr >= mid_salary_inr
      errors.add(:min_salary_inr, "must be less than midpoint salary")
    end
    if mid_salary_inr >= max_salary_inr
      errors.add(:mid_salary_inr, "must be less than maximum salary")
    end
  end
end
