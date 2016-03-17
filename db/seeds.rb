puts "Destroy previous users ... "
User.destroy_all

puts "Add new users ... "
User.create(email: 'marc@va.gov', password: 'marcmarc')
User.create(email: 'rick@va.gov', password: 'rickrick')

puts "Done ... Woo Hoo!"