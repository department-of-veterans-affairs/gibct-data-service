FactoryGirl.define do
  factory :sva do
    institution { Faker::University.name }
    student_veteran_link { Faker::Internet.url("#{institution}.edu") }

    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end      
  end
end
