class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Analytical & filtering indexes on employees table
    add_index :employees, :gender
    add_index :employees, :salary
    add_index :employees, :compa_ratio
    add_index :employees, :performance_rating
    add_index :employees, :hire_date
    add_index :employees, :employment_type

    # Composite indexes for multi-column dashboard analytics & filtering
    add_index :employees, [:department_id, :job_level_id]
    add_index :employees, [:job_level_id, :gender]
    add_index :employees, [:location_id, :department_id]
    add_index :employees, [:department_id, :salary]
  end
end
