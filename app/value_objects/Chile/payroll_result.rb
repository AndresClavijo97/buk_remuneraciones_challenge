module Chile
  class PayrollResult
    attr_reader :employee_rut, :employee_name, :base_salary, :taxable_benefits,
                :non_taxable_benefits, :legal_gratification, :legal_deductions,
                :other_deductions, :net_salary

    def initialize(
      employee_rut:, employee_name:, base_salary:, taxable_benefits:,
      non_taxable_benefits:, legal_gratification:, legal_deductions:,
      other_deductions:, net_salary:
    )
      @employee_rut = employee_rut
      @employee_name = employee_name
      @base_salary = base_salary
      @taxable_benefits = taxable_benefits
      @non_taxable_benefits = non_taxable_benefits
      @legal_gratification = legal_gratification
      @legal_deductions = legal_deductions
      @other_deductions = other_deductions
      @net_salary = net_salary
    end

    def total_taxable_income
      base_salary + taxable_benefits
    end

    def gross_taxable_income
      total_taxable_income + legal_gratification
    end

    def total_benefits
      taxable_benefits + non_taxable_benefits
    end

    def total_deductions
      legal_deductions.total + other_deductions
    end

    def total_income
      base_salary + total_benefits + legal_gratification
    end

    def to_h
      {
        employee_rut: employee_rut,
        employee_name: employee_name,
        base_salary: base_salary,
        taxable_benefits: taxable_benefits,
        non_taxable_benefits: non_taxable_benefits,
        total_taxable_income: total_taxable_income,
        legal_gratification: legal_gratification,
        gross_taxable_income: gross_taxable_income,
        legal_deductions: legal_deductions.to_h,
        other_deductions: other_deductions,
        total_deductions: total_deductions,
        total_income: total_income,
        net_salary: net_salary
      }
    end
  end
end