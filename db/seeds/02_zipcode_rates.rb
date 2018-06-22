puts 'Deleting old zipcode_rates'
ZipcodeRate.delete_all

puts 'Building Zipcode Rates'
SeedUtils.seed_table(ZipcodeRate, user)
