# frozen_string_literal: true

FactoryBot.define do
  factory :yellow_ribbon_degree_level_translation do
    raw_degree_level { 'Undergraduate' }
    translations { ['Undergraduate'] }
  end
end
