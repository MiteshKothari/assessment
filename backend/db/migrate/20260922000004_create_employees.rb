class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :gender, null: false
      t.references :department, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :job_level, null: false, foreign_key: true
      t.string :job_title, null: false
      t.string :employment_type, null: false, default: "Full-Time"
      t.date :hire_date, null: false
      t.decimal :salary, precision: 15, scale: 2, null: false
      t.decimal :bonus_percentage, precision: 5, scale: 2, default: 10.0, null: false
      t.integer :equity_shares, default: 0, null: false
      t.integer :performance_rating, default: 3, null: false
      t.decimal :compa_ratio, precision: 6, scale: 2, default: 100.0, null: false

      t.timestamps
    end

    add_index :employees, :employee_code, unique: true
    add_index :employees, :email, unique: true
  end
end
