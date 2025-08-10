module ChileanPayrollConstants
  # Valores para Junio 2025 según el README
  UF_VALUE = 37_000.0
  UTM_VALUE = 65_000.0
  IMM_VALUE = UTM_VALUE
  
  # Topes legales
  TAXABLE_INCOME_LIMIT_UF = 81.6
  TAXABLE_INCOME_LIMIT = (TAXABLE_INCOME_LIMIT_UF * UF_VALUE).round
  
  LEGAL_GRATIFICATION_LIMIT_IMM = 4.75
  MONTHLY_LEGAL_GRATIFICATION_LIMIT = ((LEGAL_GRATIFICATION_LIMIT_IMM * IMM_VALUE) / 12).round
  
  # Tasas de descuentos legales
  AFP_RATE = 0.10
  HEALTH_RATE = 0.07
  UNEMPLOYMENT_INSURANCE_RATE = 0.006
  
  # Tabla de Impuesto Único de Segunda Categoría
  INCOME_TAX_BRACKETS = [
    { min: 0, max: 746_000, rate: 0.0, fixed: 0 },
    { min: 746_001, max: 1_660_000, rate: 0.04, fixed: 0 },
    { min: 1_660_001, max: 2_760_000, rate: 0.08, fixed: 36_560 },
    { min: 2_760_001, max: 3_860_000, rate: 0.135, fixed: 273_060 },
    { min: 3_860_001, max: 5_150_000, rate: 0.23, fixed: 569_760 },
    { min: 5_150_001, max: 6_870_000, rate: 0.304, fixed: 1_092_520 },
    { min: 6_870_001, max: Float::INFINITY, rate: 0.35, fixed: 1_092_520 }
  ].freeze
end