# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_22_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.decimal "budget_inr", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.string "employee_code", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "gender", null: false
    t.bigint "department_id", null: false
    t.bigint "location_id", null: false
    t.bigint "job_level_id", null: false
    t.string "job_title", null: false
    t.string "employment_type", default: "Full-Time", null: false
    t.date "hire_date", null: false
    t.decimal "salary", precision: 15, scale: 2, null: false
    t.decimal "bonus_percentage", precision: 5, scale: 2, default: "10.0", null: false
    t.integer "equity_shares", default: 0, null: false
    t.integer "performance_rating", default: 3, null: false
    t.decimal "compa_ratio", precision: 6, scale: 2, default: "100.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compa_ratio"], name: "index_employees_on_compa_ratio"
    t.index ["department_id", "job_level_id"], name: "index_employees_on_department_id_and_job_level_id"
    t.index ["department_id", "salary"], name: "index_employees_on_department_id_and_salary"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["employment_type"], name: "index_employees_on_employment_type"
    t.index ["gender"], name: "index_employees_on_gender"
    t.index ["hire_date"], name: "index_employees_on_hire_date"
    t.index ["job_level_id", "gender"], name: "index_employees_on_job_level_id_and_gender"
    t.index ["job_level_id"], name: "index_employees_on_job_level_id"
    t.index ["location_id", "department_id"], name: "index_employees_on_location_id_and_department_id"
    t.index ["location_id"], name: "index_employees_on_location_id"
    t.index ["performance_rating"], name: "index_employees_on_performance_rating"
    t.index ["salary"], name: "index_employees_on_salary"
  end

  create_table "job_levels", force: :cascade do |t|
    t.string "name", null: false
    t.integer "grade", null: false
    t.decimal "min_salary_inr", precision: 15, scale: 2, null: false
    t.decimal "mid_salary_inr", precision: 15, scale: 2, null: false
    t.decimal "max_salary_inr", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade"], name: "index_job_levels_on_grade", unique: true
    t.index ["name"], name: "index_job_levels_on_name", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "city", null: false
    t.string "country", null: false
    t.string "office_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "country"], name: "index_locations_on_city_and_country", unique: true
  end

  create_table "salary_histories", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.decimal "previous_salary", precision: 15, scale: 2, null: false
    t.decimal "new_salary", precision: 15, scale: 2, null: false
    t.decimal "change_percentage", precision: 6, scale: 2, null: false
    t.string "change_reason", null: false
    t.date "effective_date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.index ["effective_date"], name: "index_salary_histories_on_effective_date"
    t.index ["employee_id"], name: "index_salary_histories_on_employee_id"
  end

  add_foreign_key "employees", "departments"
  add_foreign_key "employees", "job_levels"
  add_foreign_key "employees", "locations"
  add_foreign_key "salary_histories", "employees"
end
