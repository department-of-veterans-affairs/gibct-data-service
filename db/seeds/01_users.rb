if ENV['CI'].blank?
  puts 'Destroy previous users ... '
  User.destroy_all

  user = User.create(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PW'])
  unless user.persisted?
    puts "Error creating #{user.email}: "
  else
    puts 'created user.'
  end
end