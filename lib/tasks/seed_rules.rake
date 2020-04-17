# frozen_string_literal: true

namespace :db do
  desc 'Seeds rules, caution_flag_rules from db/seeds/03_rules.rb'
  task :seed_rules, [:seed_filename] => [:environment] do |_task, args|
    file = args[:seed_filename] || '03_rules.rb'
    load Rails.root.join('db', 'seeds', file)
  end
end
