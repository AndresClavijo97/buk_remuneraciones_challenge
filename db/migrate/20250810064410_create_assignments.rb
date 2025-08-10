class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :name, null: false
      t.string :assignment_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.boolean :taxable, default: false, null: false
      t.boolean :tributable, default: false, null: false

      t.timestamps
    end
  end
end
