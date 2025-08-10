class HealthPlan < ApplicationRecord
  belongs_to :employee

  validates :plan_type, presence: true, inclusion: { in: %w[fonasa isapre] }
  validates :plan_uf, numericality: { greater_than: 0, allow_nil: true }

  def fonasa?
    plan_type == 'fonasa'
  end

  def isapre?
    plan_type == 'isapre'
  end
end
