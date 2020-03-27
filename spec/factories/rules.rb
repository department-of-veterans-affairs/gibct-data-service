FactoryBot.define do
  factory :rule do
    type { "" }
    matcher { "MyString" }
    subject { "MyString" }
    object { "MyString" }
    predicate { "MyString" }
  end
end
