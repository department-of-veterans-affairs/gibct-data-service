if ENV['CI'].blank?
  
  user = User.first

  puts 'Building Institutions'
  result = InstitutionBuilder.run(user)

  if result[:success]
    puts "Setting version: #{result[:version].number} as production"
    version = Version.current_preview
    version.update(production: true)
  else
    puts "Error occurred: #{result[:notice]}: #{result[:error_msg]}"
  end

  puts 'Building CrosswalkIssues'
  CrosswalkIssue.rebuild

  puts "Done ... Woo Hoo!"
end


