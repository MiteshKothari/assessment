module Api
  module V1
    class ReferenceDataController < ApplicationController
      def index
        departments = Department.order(:name).select(:id, :name, :code, :budget_inr)
        locations = Location.order(:country, :city).select(:id, :city, :country, :office_name)
        job_levels = JobLevel.order(:grade).select(:id, :name, :grade, :min_salary_inr, :mid_salary_inr, :max_salary_inr)

        render json: {
          departments: departments,
          locations: locations,
          job_levels: job_levels,
          genders: Employee::GENDERS,
          employment_types: Employee::EMPLOYMENT_TYPES,
          performance_ratings: Employee::PERFORMANCE_RATINGS,
          adjustment_reasons: SalaryHistory::REASONS
        }
      end
    end
  end
end
