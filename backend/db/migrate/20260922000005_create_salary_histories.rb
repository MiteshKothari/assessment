class CreateSalaryHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :salary_histories do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :previous_salary, precision: 15, scale: 2, null: false
      t.decimal :new_salary, precision: 15, scale: 2, null: false
      t.decimal :change_percentage, precision: 6, scale: 2, null: false
      t.string :change_reason, null: false
      t.date :effective_date, null: false
      t.text :notes

      t.datetime :created_at, null: false
    end

    add_index :salary_histories, :effective_date
  end
end
