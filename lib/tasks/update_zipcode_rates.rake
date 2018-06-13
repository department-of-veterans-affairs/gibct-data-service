# frozen_string_literal: true

namespace :db do
  desc 'Updates zipcode_rates from db/seeds/02_zipcode_rates.rb'
  task :update_zipcode_rates, [:constants_file] => [:environment] do |_task, args|
    file = args[:constants_file] || '02_zipcode_rates.rb'
    load Rails.root.join('db', 'seeds', file)
  end
end
