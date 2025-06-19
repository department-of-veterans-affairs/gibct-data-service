FactoryBot.define do
  factory :calculator_constant_version do
    version { nil }
    name { "MyString" }
    float_value { 1.5 }
    description { "MyString" }
  end
end
