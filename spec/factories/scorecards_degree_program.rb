# frozen_string_literal: true

FactoryBot.define do
  factory :scorecard_degree_program do
    unitid { 1 }
    ope6_id { '1' }
    control { 1 }
    main {  1 }
    cip_code { '1' }
    cip_desc { 'desc' }
    cred_lev { 1 }
    cred_desc { 'b' }
  end
end
