if ENV['CI'].blank?
  
  user = User.first

  puts 'Building Institutions'
=begin  
  result = InstitutionBuilder.run(user)
byebug
  if result[:success]
    puts "Setting version: #{result[:version].number} as production"
    version = Version.current_preview
    version.update(production: true)
  else
    puts "Error occurred: #{result[:notice]}: #{result[:error_msg]}"
  end
=end
  InstitutionBuilder.run(user)

  version = Version.current_preview
  if version
    puts "Setting version: #{version.number} as production"
    version.update(production: true)

    puts 'Building CrosswalkIssues'
    CrosswalkIssue.rebuild
  
    puts "Done ... Woo Hoo!"
  else
    puts "Error occurred - check the logs"
  end
end


