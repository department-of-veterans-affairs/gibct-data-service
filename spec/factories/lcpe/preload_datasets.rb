# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_preload_dataset, class: 'Lcpe::PreloadDataset' do
    body { [{ some_attribute: 'value' }].to_json }
  end
end
