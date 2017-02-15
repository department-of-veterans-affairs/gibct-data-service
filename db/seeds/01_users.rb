puts 'Destroy previous users ... '
User.destroy_all

puts 'Add new users ... '
User.create(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PW'])
