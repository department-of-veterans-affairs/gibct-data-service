# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "Destroy previous users ... "
User.destroy_all

puts "Add new users ... "
User.create(email: 'marc@va.gov', password: 'marcmarc')
User.create(email: 'rick@va.gov', password: 'rickrick')

puts "Destroy previous file sources and CSV files ... "
RawFileSource.destroy_all

puts "Mapping STI types to raw file sources ... "
[ 'school_file', 'weams_file', 'ipeds', 'crosswalk', 'scorecard', 'ipeds hd', 'ipeds ic',
	'ipeds ic sc ay', 'ipeds ic sc py', 'p911 tf', 'p911 yr', 'sec702',
	'sec702 school', 'accredit', 'hcm', 'complaint', 'vsoc', '8keys',
	'mou', 'arf', 'sva'
].each_with_index do |source, i|
	RawFileSource.create(name: source, build_order: i + 1)
end

puts "Creating CSV file storage for each source ... "
RawFileSource.all.each do |source|
	source.create_csv_file(data: 0)
end

puts "Done ... Woo Hoo!"