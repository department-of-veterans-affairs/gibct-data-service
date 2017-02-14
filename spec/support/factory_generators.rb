# frozen_string_literal: true
FactoryGirl.define do
  sequence(:facility_code) do |n|
    n.to_s(32).rjust(8, '0').upcase
  end

  sequence(:facility_code_ojt) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[1] = '0'
    fc.upcase
  end

  sequence(:facility_code_public) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[0, 2] = '11'
    fc.upcase
  end

  sequence(:facility_code_for_profit) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[0, 2] = '21'
    fc.upcase
  end

  sequence(:facility_code_private) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[0, 2] = '31'
    fc.upcase
  end

  sequence(:ope) do |n|
    n.to_s.rjust(8, '0')
  end

  sequence(:cross) do |n|
    n.to_s.rjust(6, '0')
  end
end
