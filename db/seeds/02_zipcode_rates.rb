puts 'Deleting old Zipcode Rates' # klass.load will delete_all
puts 'Building Zipcode Rates'
SeedUtils.seed_table(ZipcodeRate, Rails.root.join('sample_csvs', 'zipcode_rate.csv'))
