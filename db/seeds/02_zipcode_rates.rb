puts 'Deleting old Zipcode Rates'
ZipcodeRate.delete_all

puts 'Building Zipcode Rates'
SeedUtils.seed_table(ZipcodeRate, Rails.root.join('sample_csvs', 'zipcode_rate.csv'))
