if ENV['CI'].blank?
  Dir[File.join(Rails.root, 'db', 'seeds', 'models', '*.yml')].each do |path|
    klass = File.basename(path, '.yml').classify.constantize
    
    puts "Deleting old #{klass.name.pluralize}"
    klass.destroy_all

    puts "Seeding #{klass.name.pluralize} ... "
    seeds = YAML.load_file(path)
    seeds.each do |attributes|
      klass.create(attributes)
    end
  end

  # Associate existing calculator constants with rate adjustment
  CalculatorConstant.all.each { |constant| constant.set_rate_adjustment_if_exists }
end
