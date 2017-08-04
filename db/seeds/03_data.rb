def seed_table(klass, user, options = {})
  csv_name = "#{klass.name.underscore}.csv"
  csv_type = klass.name
  csv_path = 'sample_csvs'

  print "Loading #{klass.name} from #{csv_path}/#{csv_name} ... "

  uf = ActionDispatch::Http::UploadedFile.new(
    tempfile: File.new(Rails.root.join(csv_path, csv_name)),
    filename: csv_name,
    type: 'text/csv'
  )

  upload = Upload.create(upload_file: uf, csv_type: csv_type, comment: 'Seeding', user: user)
  klass.load("#{csv_path}/#{csv_name}", options)
  upload.update(ok: true)

  puts 'Done!'
end

user = User.first

puts 'Deleting old versions'
Version.delete_all

puts 'Deleting old uploads data'
Upload.delete_all

puts 'Deleting old institutions'
Institution.delete_all

puts 'Loading CSVs, why not go get a nice cup of coffee while you wait? ... '
seed_table(Weam, user)
seed_table(Crosswalk, user)
seed_table(EightKey, user, skip_lines: 1)
seed_table(Accreditation, user)
seed_table(ArfGiBill, user)
seed_table(Scorecard, user)
seed_table(P911Tf, user)
seed_table(P911Yr, user)
seed_table(Vsoc, user)
seed_table(Sva, user)
seed_table(Sec702, user)
seed_table(Sec702School, user)
seed_table(Mou, user, skip_lines: 1)
seed_table(Hcm, user, skip_lines: 2)
seed_table(Settlement, user)
seed_table(IpedsIc, user)
seed_table(IpedsIcAy, user)
seed_table(IpedsIcPy, user)
seed_table(IpedsHd, user)
seed_table(Complaint, user, skip_lines: 7)
seed_table(Outcome, user)

puts 'Building Institutions'
result = InstitutionBuilder.run(user)

puts "Setting version: #{result[:version].number} as production"
Version.create(user: user, number: result[:version].number, production: true)

puts "Done ... Woo Hoo!"
