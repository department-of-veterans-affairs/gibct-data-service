# frozen_string_literal: true

FactoryBot.define do
  factory :census_lat_long do
    facility_code { generate :facility_code }
    input_address { '4600 Silver Hill Road, Washington, DC, 20233' }
    tiger_address_range_match_indicator { 'Match' }
    tiger_match_type { 'Exact' }
    tiger_output_address { '4600 SILVER HILL RD, WASHINGTON, DC, 20233' }
    tiger_line_id { '76355984' }
    tiger_line_id_side { 'L' }
  end
end
