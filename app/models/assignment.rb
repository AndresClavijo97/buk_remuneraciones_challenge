class Assignment < ApplicationRecord
  belongs_to :employee

  validates :name, presence: true
  validates :assignment_type, presence: true, inclusion: { in: %w[benefit deduction] }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :taxable, inclusion: { in: [true, false] }
  validates :tributable, inclusion: { in: [true, false] }

  scope :benefits, -> { where(assignment_type: 'benefit') }
  scope :deductions, -> { where(assignment_type: 'deduction') }
  scope :taxable_items, -> { where(taxable: true) }
  scope :non_taxable_items, -> { where(taxable: false) }
end
