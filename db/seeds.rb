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

puts "Destroy previous file sources ... "
RawFileSource.destroy_all

puts "Adding raw file sources ... "
RawFileSource.create(name: 'weams')
RawFileSource.create(name: 'crosswalk')
RawFileSource.create(name: 'scorecard')
RawFileSource.create(name: 'ipeds hd')
RawFileSource.create(name: 'arf')
RawFileSource.create(name: 'sva')
RawFileSource.create(name: '8keys')
RawFileSource.create(name: 'mou')
RawFileSource.create(name: 'sec702')
RawFileSource.create(name: 'sec702 school')
RawFileSource.create(name: 'vsoc')
RawFileSource.create(name: 'ipeds ic')
RawFileSource.create(name: 'ipeds')
RawFileSource.create(name: 'ipeds ic sc ay')
RawFileSource.create(name: 'ipeds ic sc py')
RawFileSource.create(name: 'p911 tf')
RawFileSource.create(name: 'p911 yr')
RawFileSource.create(name: 'accredit')
RawFileSource.create(name: 'hcm')
RawFileSource.create(name: 'complaint')

puts "Done ... Woo Hoo!"