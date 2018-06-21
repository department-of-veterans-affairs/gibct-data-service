Dir[File.join(Rails.root, 'db', 'seeds', '99_*.rb')].sort.each { |seed| load seed }
