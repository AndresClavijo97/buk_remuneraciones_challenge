class Employee < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_one :health_plan, dependent: :destroy

  accepts_nested_attributes_for :assignments, allow_destroy: true
  accepts_nested_attributes_for :health_plan, allow_destroy: true

  validates :rut, presence: true, uniqueness: true
  validates :name, presence: true
  validates :hire_date, presence: true
  validates :base_salary, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
