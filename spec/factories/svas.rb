FactoryGirl.define do
  factory :sva do
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end      

    institution { Faker::University.name }
    student_veteran_link { Faker::Internet.url("#{institution}.edu") }
  end
end
