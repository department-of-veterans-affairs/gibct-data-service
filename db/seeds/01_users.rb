if ENV['CI'].blank?
  puts 'Destroy previous users ... '
  User.destroy_all

  user = User.create(email: ENV.fetch('ADMIN_EMAIL'), password: ENV.fetch('ADMIN_PW'))
  unless user.persisted?
    puts "Error creating #{user.email}: "
    raise
  else
    puts 'created user.'
  end
end
