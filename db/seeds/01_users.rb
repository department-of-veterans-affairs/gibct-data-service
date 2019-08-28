puts 'Destroy previous users ... '
User.destroy_all

puts 'Add new users ... '

# User.create(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PW'])
user = User.create(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PW'])
unless user.valid?
  puts "Error creating #{user.email}: "

  if user.errors.messages[:email].try(:first).match?(/invalid/i)
    puts '   Only .gov emails are permitted!'
  end
else
  puts 'created user.'
end

# Add additional users
# User.create(email: 'xxxxxx', password: 'xxxxxx')
