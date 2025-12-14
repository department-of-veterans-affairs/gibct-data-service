return unless ENV['CI'].blank?

user = User.first

puts 'Building Institutions'
InstitutionBuilder.run(user)

puts 'Building CrosswalkIssues'
CrosswalkIssue.rebuild
puts "Done ... Woo Hoo!!"
