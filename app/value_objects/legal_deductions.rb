class LegalDeductions
  attr_reader :afp, :health, :unemployment_insurance, :income_tax

  def initialize(afp:, health:, unemployment_insurance:, income_tax:)
    @afp = afp
    @health = health
    @unemployment_insurance = unemployment_insurance
    @income_tax = income_tax
  end

  def total
    afp + health + unemployment_insurance + income_tax
  end

  def to_h
    {
      afp: afp,
      health: health,
      unemployment_insurance: unemployment_insurance,
      income_tax: income_tax,
      total: total
    }
  end
end