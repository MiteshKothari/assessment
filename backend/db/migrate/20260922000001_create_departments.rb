class CreateDepartments < ActiveRecord::Migration[7.2]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.decimal :budget_inr, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :departments, :name, unique: true
    add_index :departments, :code, unique: true
  end
end
