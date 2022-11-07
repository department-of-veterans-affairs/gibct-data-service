# frozen_string_literal: true

FactoryBot.define do
  factory :preview_generation_status_information do
    current_progress { 'Preview Version is being generated.' }
  end
end
