class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :city, null: false
      t.string :country, null: false
      t.string :office_name, null: false

      t.timestamps
    end

    add_index :locations, [:city, :country], unique: true
  end
end
