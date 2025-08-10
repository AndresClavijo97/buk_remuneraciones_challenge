FactoryBot.define do
  factory :assignment do
    employee { nil }
    name { "MyString" }
    assignment_type { "MyString" }
    amount { "9.99" }
    taxable { false }
    tributable { false }
  end
end
