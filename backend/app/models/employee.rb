class Employee < ApplicationRecord
  belongs_to :department
  belongs_to :location
  belongs_to :job_level
  has_many :salary_histories, -> { order(effective_date: :desc, created_at: :desc) }, dependent: :destroy

  GENDERS = %w[Male Female Non-Binary].freeze
  EMPLOYMENT_TYPES = %w[Full-Time Contract Part-Time].freeze
  PERFORMANCE_RATINGS = (1..5).to_a.freeze

  validates :employee_code, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :gender, inclusion: { in: GENDERS }
  validates :employment_type, inclusion: { in: EMPLOYMENT_TYPES }
  validates :job_title, presence: true
  validates :hire_date, presence: true
  validates :salary, numericality: { greater_than: 0 }
  validates :bonus_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :equity_shares, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :performance_rating, inclusion: { in: PERFORMANCE_RATINGS }

  before_validation :compute_compa_ratio

  # Analytical and filtering scopes
  scope :search_query, ->(q) {
    return all if q.blank?
    term = "%#{q.strip.downcase}%"
    where(
      "LOWER(employee_code) LIKE :t OR LOWER(first_name) LIKE :t OR LOWER(last_name) LIKE :t OR LOWER(email) LIKE :t OR LOWER(job_title) LIKE :t",
      t: term
    )
  }

  scope :filter_by_department, ->(dept_id) { where(department_id: dept_id) if dept_id.present? }
  scope :filter_by_location, ->(loc_id) { where(location_id: loc_id) if loc_id.present? }
  scope :filter_by_job_level, ->(lvl_id) { where(job_level_id: lvl_id) if lvl_id.present? }
  scope :filter_by_performance, ->(rating) { where(performance_rating: rating) if rating.present? }
  scope :filter_by_compa_status, ->(status) {
    case status.to_s.downcase
    when "underpaid"
      where("compa_ratio < 80")
    when "in_band"
      where("compa_ratio >= 80 AND compa_ratio <= 120")
    when "overpaid"
      where("compa_ratio > 120")
    else
      all
    end
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def compute_compa_ratio
    if job_level&.mid_salary_inr && salary.present? && job_level.mid_salary_inr.positive?
      self.compa_ratio = ((salary / job_level.mid_salary_inr) * 100).round(2)
    end
  end

  # Perform audited salary adjustment
  def adjust_salary!(new_salary:, change_reason:, notes: nil, effective_date: Date.current)
    new_salary = BigDecimal(new_salary.to_s)
    raise ArgumentError, "New salary must be greater than zero" if new_salary <= 0
    raise ArgumentError, "Change reason is required" if change_reason.blank?

    old_salary = self.salary
    change_pct = old_salary.positive? ? (((new_salary - old_salary) / old_salary) * 100).round(2) : 0.0

    transaction do
      salary_histories.create!(
        previous_salary: old_salary,
        new_salary: new_salary,
        change_percentage: change_pct,
        change_reason: change_reason,
        effective_date: effective_date,
        notes: notes
      )

      self.salary = new_salary
      compute_compa_ratio
      save!
    end
  end
end
