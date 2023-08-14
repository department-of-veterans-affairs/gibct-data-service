# frozen_string_literal: true

FactoryBot.define do
  factory :section1015 do
    facility_code { '1ZZZZZZZ' }
    institution { 'NORTHEASTERN ILLINOIS UNIVERSITY' }
    celo { 'y' }

    trait(:celo_n) do
      facility_code { '2ZZZZZZZ' }
      institution { 'NORTHWESTERN UNIVERSITY' }
      celo { 'n' }
    end
  end
end
