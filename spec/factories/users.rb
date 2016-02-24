FactoryGirl.define do
  factory :user do
    email { "#{Faker::Name.last_name}.#{Faker::Name.first_name}@va.gov" }
    password { "#{Faker::Internet.password}" }

    trait :bad_email do
    	email "abc@com"
    end

    trait :bad_email_domain do
    	email "abc@something.com"
    end

    trait :no_email do
    	email ""
    end

    trait :short_password do
    	password { "#{Faker::Internet.password(7, 7)}" }
    end

    trait :long_password do
    	password { "#{Faker::Internet.password(73, 73)}" }
    end

    trait :no_password do
    	password ""
    end
  end
end
