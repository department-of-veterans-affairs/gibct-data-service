# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_preload_dataset, class: 'Lcpe::PreloadDataset' do
    body { 'MyText' }
    subject_class { 'MyString' }
  end
end
