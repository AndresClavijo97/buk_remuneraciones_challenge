class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :rut, null: false
      t.string :name, null: false
      t.date :hire_date, null: false
      t.decimal :base_salary, precision: 10, scale: 2, null: false

      t.timestamps
    end
    
    add_index :employees, :rut, unique: true
  end
end
