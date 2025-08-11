class ChilePayroll < ApplicationPayroll
  include ChileRules

  def initialize(employee)
    @employee = ::Chile::EmployeeValue.new(employee)
  end

  def calculate
    ::Chile::PayrollResult.new(
      employee_rut: @employee.rut,
      employee_name: @employee.name,
      base_salary: @employee.base_salary,
      taxable_benefits: @employee.taxable_benefits_total,
      non_taxable_benefits: @employee.non_taxable_benefits_total,
      legal_gratification: legal_gratification,
      legal_deductions: calculate_legal_deductions,
      other_deductions: @employee.other_deductions_total,
      net_salary: calculate_net_salary
    )
  end

  private

  def total_taxable_income
    @employee.base_salary + @employee.taxable_benefits_total
  end

  def legal_gratification
    gratification = (total_taxable_income * 0.25).round
    [gratification, MONTHLY_LEGAL_GRATIFICATION_LIMIT].min
  end

  def gross_taxable_income
    total_taxable_income + legal_gratification
  end

  def capped_taxable_income
    [gross_taxable_income, TAXABLE_INCOME_LIMIT].min
  end

  def calculate_legal_deductions
    ::Chile::LegalDeductions.new(
      afp: calculate_afp,
      health: calculate_health,
      unemployment_insurance: calculate_unemployment_insurance,
      income_tax: calculate_income_tax
    )
  end

  def calculate_afp
    (capped_taxable_income * AFP_RATE).round
  end

  def calculate_health
    if @employee.has_isapre_plan? && @employee.health_plan_uf
      (@employee.health_plan_uf * UF_VALUE).round
    else
      (capped_taxable_income * HEALTH_RATE).round
    end
  end

  def calculate_unemployment_insurance
    (gross_taxable_income * UNEMPLOYMENT_INSURANCE_RATE).round
  end

  def calculate_income_tax
    afp = calculate_afp
    health = calculate_health
    unemployment = calculate_unemployment_insurance
    
    taxable_for_tax = gross_taxable_income - afp - health - unemployment
    return 0 if taxable_for_tax <= 0

    bracket = find_tax_bracket(taxable_for_tax)
    return 0 unless bracket

    excess = taxable_for_tax - bracket[:min]
    (bracket[:fixed] + (excess * bracket[:rate])).round
  end

  def find_tax_bracket(amount)
    INCOME_TAX_BRACKETS.find { |bracket| amount >= bracket[:min] && amount <= bracket[:max] }
  end

  def calculate_net_salary
    total_deductions = calculate_legal_deductions.total + @employee.other_deductions_total
    
    (total_income - total_deductions).round
  end

  def total_income
    @employee.base_salary + @employee.taxable_benefits_total + @employee.non_taxable_benefits_total + legal_gratification
  end
end