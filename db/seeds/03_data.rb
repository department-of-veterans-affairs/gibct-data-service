require 'seed_utils'

user = User.first

puts 'Deleting old versions'
Version.delete_all

puts 'Deleting old uploads data'
Upload.delete_all

puts 'Deleting old institutions'
Institution.delete_all

puts 'Deleting old constants'
CalculatorConstant.delete_all

puts 'Loading CSVs, why not go get a nice cup of coffee while you wait? ... '
SeedUtils.seed_table(CalculatorConstant, user)
SeedUtils.seed_table(Weam, user)
SeedUtils.seed_table(Crosswalk, user)
SeedUtils.seed_table(EightKey, user, skip_lines: 1)
SeedUtils.seed_table(Accreditation, user)
SeedUtils.seed_table(ArfGiBill, user)
SeedUtils.seed_table(Scorecard, user)
SeedUtils.seed_table(P911Tf, user)
SeedUtils.seed_table(P911Yr, user)
SeedUtils.seed_table(Vsoc, user)
SeedUtils.seed_table(Sva, user)
SeedUtils.seed_table(Sec702, user)
SeedUtils.seed_table(Sec702School, user)
SeedUtils.seed_table(Mou, user, skip_lines: 1)
SeedUtils.seed_table(Hcm, user, skip_lines: 2)
SeedUtils.seed_table(Settlement, user)
SeedUtils.seed_table(IpedsIc, user)
SeedUtils.seed_table(IpedsIcAy, user)
SeedUtils.seed_table(IpedsIcPy, user)
SeedUtils.seed_table(IpedsHd, user)
SeedUtils.seed_table(Complaint, user, skip_lines: 7)
SeedUtils.seed_table(Outcome, user)

puts 'Building Institutions'
result = InstitutionBuilder.run(user)

puts "Setting version: #{result[:version].number} as production"
Version.create(user: user, number: result[:version].number, production: true)

puts "Done ... Woo Hoo!"
