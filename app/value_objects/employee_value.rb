class EmployeeValue
  delegate_missing_to :@employee
  
  def initialize(employee)
    @employee = employee
  end

  def taxable_benefits_total
    taxable_benefits.sum(&:amount)
  end

  def non_taxable_benefits_total
    non_taxable_benefits.sum(&:amount)
  end

  def other_deductions_total
    deductions.sum(&:amount)
  end

  def has_isapre_plan?
    health_plan&.isapre?
  end

  def health_plan_uf
    health_plan&.plan_uf
  end

  private

  def taxable_benefits
    assignments.benefits.taxable_items
  end

  def non_taxable_benefits
    assignments.benefits.non_taxable_items
  end

  def deductions
    assignments.deductions
  end
end