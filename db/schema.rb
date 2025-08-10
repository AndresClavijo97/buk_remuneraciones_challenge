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

ActiveRecord::Schema[8.0].define(version: 2025_08_10_064605) do
  create_table "assignments", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.string "name", null: false
    t.string "assignment_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.boolean "taxable", default: false, null: false
    t.boolean "tributable", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_assignments_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.string "rut", null: false
    t.string "name", null: false
    t.date "hire_date", null: false
    t.decimal "base_salary", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rut"], name: "index_employees_on_rut", unique: true
  end

  create_table "health_plans", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.string "plan_type", null: false
    t.decimal "plan_uf", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_health_plans_on_employee_id", unique: true
  end

  add_foreign_key "assignments", "employees"
  add_foreign_key "health_plans", "employees"
end
