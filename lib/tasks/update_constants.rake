# frozen_string_literal: true
namespace :db do
  desc 'Updates calculator constants from db/seeds/02_constants.rb'
  task :update_constants, [:constants_file] => [:environment] do |_task, args|
    file = args[:constants_file] || '02_constants.rb'
    load File.join(Rails.root, 'db', 'seeds', file)
  end
end
