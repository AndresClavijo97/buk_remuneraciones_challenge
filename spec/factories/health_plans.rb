FactoryBot.define do
  factory :health_plan do
    employee { nil }
    plan_type { "MyString" }
    plan_uf { "9.99" }
  end
end
