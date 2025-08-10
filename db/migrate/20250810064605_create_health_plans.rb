class CreateHealthPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :health_plans do |t|
      t.references :employee, null: false, foreign_key: true, index: { unique: true }
      t.string :plan_type, null: false
      t.decimal :plan_uf, precision: 8, scale: 2

      t.timestamps
    end
  end
end
