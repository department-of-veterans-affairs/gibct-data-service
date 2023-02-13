if ENV['CI'].blank?
  user = User.first

  puts 'Building Institutions'
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
