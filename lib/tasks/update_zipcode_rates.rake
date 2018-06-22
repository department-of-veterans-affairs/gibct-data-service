# frozen_string_literal: true

require 'seed_utils'

namespace :db do
  desc 'Updates zipcode_rates from db/seeds/02_zipcode_rates.rb'
  task :update_zipcode_rates, [:seed_filename] => [:environment] do |_task, args|
    file = args[:seed_filename] || '02_zipcode_rates.rb'
    load Rails.root.join('db', 'seeds', file)
  end
end
