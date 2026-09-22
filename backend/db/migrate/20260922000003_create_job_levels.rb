class CreateJobLevels < ActiveRecord::Migration[7.2]
  def change
    create_table :job_levels do |t|
      t.string :name, null: false
      t.integer :grade, null: false
      t.decimal :min_salary_inr, precision: 15, scale: 2, null: false
      t.decimal :mid_salary_inr, precision: 15, scale: 2, null: false
      t.decimal :max_salary_inr, precision: 15, scale: 2, null: false

      t.timestamps
    end

    add_index :job_levels, :grade, unique: true
    add_index :job_levels, :name, unique: true
  end
end
