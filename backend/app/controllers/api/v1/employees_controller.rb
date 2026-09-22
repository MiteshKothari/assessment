require "csv"

module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :set_employee, only: [:show, :adjust_salary]

      # GET /api/v1/employees
      def index
        scope = Employee.includes(:department, :location, :job_level)
                        .search_query(params[:search])
                        .filter_by_department(params[:department_id])
                        .filter_by_location(params[:location_id])
                        .filter_by_job_level(params[:job_level_id])
                        .filter_by_performance(params[:performance_rating])
                        .filter_by_compa_status(params[:compa_status])

        total_count = scope.count

        # Sorting
        sort_column = allowed_sort_columns[params[:sort_by]] || "employees.id"
        sort_order = params[:sort_order].to_s.downcase == "desc" ? "DESC" : "ASC"
        scope = scope.order("#{sort_column} #{sort_order}")

        # Pagination
        page = [params[:page].to_i, 1].max
        per_page = [params[:per_page].to_i, 25].max
        per_page = [per_page, 100].min # cap at 100
        offset = (page - 1) * per_page

        employees = scope.limit(per_page).offset(offset)
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          employees: employees.map { |e| serialize_employee(e) },
          meta: {
            current_page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      # GET /api/v1/employees/:id
      def show
        render json: {
          employee: serialize_employee_detailed(@employee)
        }
      end

      # POST /api/v1/employees/:id/adjust_salary
      def adjust_salary
        new_salary = params[:new_salary]
        change_reason = params[:change_reason]
        notes = params[:notes]
        effective_date = params[:effective_date].present? ? Date.parse(params[:effective_date]) : Date.current

        @employee.adjust_salary!(
          new_salary: new_salary,
          change_reason: change_reason,
          notes: notes,
          effective_date: effective_date
        )

        render json: {
          message: "Salary successfully updated",
          employee: serialize_employee_detailed(@employee.reload)
        }, status: :ok
      end

      # GET /api/v1/employees/export
      def export
        scope = Employee.includes(:department, :location, :job_level)
                        .search_query(params[:search])
                        .filter_by_department(params[:department_id])
                        .filter_by_location(params[:location_id])
                        .filter_by_job_level(params[:job_level_id])
                        .filter_by_performance(params[:performance_rating])
                        .filter_by_compa_status(params[:compa_status])
                        .order("employees.id ASC")
                        .limit(5_000)

        csv_data = CSV.generate(headers: true) do |csv|
          csv << [
            "Employee Code", "Full Name", "Email", "Gender", "Department",
            "Location", "Job Level", "Job Title", "Employment Type",
            "Hire Date", "Salary (INR)", "Bonus %", "Equity Shares",
            "Performance Rating", "Compa-Ratio (%)"
          ]

          scope.find_each do |e|
            csv << [
              e.employee_code,
              e.full_name,
              e.email,
              e.gender,
              e.department.name,
              e.location.city,
              e.job_level.name,
              e.job_title,
              e.employment_type,
              e.hire_date.to_s,
              e.salary.to_f,
              e.bonus_percentage.to_f,
              e.equity_shares,
              e.performance_rating,
              e.compa_ratio.to_f
            ]
          end
        end

        send_data csv_data,
                  filename: "acme_employees_#{Date.current}.csv",
                  type: "text/csv; charset=utf-8"
      end

      private

      def set_employee
        @employee = Employee.includes(:department, :location, :job_level, :salary_histories).find(params[:id])
      end

      def allowed_sort_columns
        {
          "salary" => "employees.salary",
          "name" => "employees.first_name",
          "hire_date" => "employees.hire_date",
          "performance_rating" => "employees.performance_rating",
          "compa_ratio" => "employees.compa_ratio",
          "job_title" => "employees.job_title",
          "employee_code" => "employees.employee_code"
        }
      end

      def serialize_employee(e)
        {
          id: e.id,
          employee_code: e.employee_code,
          first_name: e.first_name,
          last_name: e.last_name,
          name: e.full_name,
          email: e.email,
          gender: e.gender,
          department_id: e.department_id,
          department_name: e.department.name,
          location_id: e.location_id,
          location_city: e.location.city,
          location_country: e.location.country,
          job_level_id: e.job_level_id,
          job_level_name: e.job_level.name,
          job_level_grade: e.job_level.grade,
          job_title: e.job_title,
          employment_type: e.employment_type,
          hire_date: e.hire_date.to_s,
          salary: e.salary.to_f,
          bonus_percentage: e.bonus_percentage.to_f,
          equity_shares: e.equity_shares,
          performance_rating: e.performance_rating,
          compa_ratio: e.compa_ratio.to_f
        }
      end

      def serialize_employee_detailed(e)
        serialize_employee(e).merge(
          job_level_min_salary: e.job_level.min_salary_inr.to_f,
          job_level_mid_salary: e.job_level.mid_salary_inr.to_f,
          job_level_max_salary: e.job_level.max_salary_inr.to_f,
          salary_histories: e.salary_histories.map do |h|
            {
              id: h.id,
              previous_salary: h.previous_salary.to_f,
              new_salary: h.new_salary.to_f,
              change_percentage: h.change_percentage.to_f,
              change_reason: h.change_reason,
              effective_date: h.effective_date.to_s,
              notes: h.notes,
              created_at: h.created_at.iso8601
            }
          end
        )
      end
    end
  end
end
