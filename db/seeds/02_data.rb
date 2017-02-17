puts 'Creating sample constants'
constants = {
  'TFCAP' => 21970.46,
  'AVGBAH' => 1611,
  'BSCAP' => 1000,
  'BSOJTMONTH' => 83,
  'FLTTFCAP' => 12554.54,
  'CORRESPONDTFCAP' => 10671.35,
  'MGIB3YRRATE' => 1857,
  'MGIB2YRRATE' => 1509,
  'SRRATE' => 369,
  'DEARATE' => 1024,
  'DEARATEOJT' => 747,
  'VRE0DEPRATE' => 605.44,
  'VRE1DEPRATE' => 751.00,
  'VRE2DEPRATE' => 885.00,
  'VREINCRATE' => 64.50,
  'VRE0DEPRATEOJT' => 529.36,
  'VRE1DEPRATEOJT' => 640.15,
  'VRE2DEPRATEOJT' => 737.77,
  'VREINCRATEOJT' => 47.99,
  'AVERETENTIONRATE' => 67.9,
  'AVEGRADRATE' => 41.5,
  'AVESALARY' => 33_500,
  'AVEREPAYMENTRATE' => 45.9
}.map { |k,v| {name: k, float_value: v} }
CalculatorConstant.create(constants)

user = User.first

puts 'Deleting old versions'
Version.delete_all

puts 'Deleting old uploads data'
Upload.delete_all

puts 'Loading CSVs, why not go get a nice cup of coffee while you wait? ... '
puts 'Loading Weam'
Weam.load('sample_csvs/weam.csv', user, 'Loaded via seeds')

puts 'Loading Crosswalk'
Crosswalk.load('sample_csvs/crosswalk.csv', user, 'Loaded via seeds')

puts 'Loading EightKey'
EightKey.load('sample_csvs/eight_key.csv', user, 'Loaded via seeds', skip_lines: 1)

puts 'Loading Accreditation'
Accreditation.load('sample_csvs/accreditation.csv', user, 'Loaded via seeds')

puts 'Loading ArfGiBill'
ArfGiBill.load('sample_csvs/arf.csv', user, 'Loaded via seeds')

puts 'Loading Scorecard'
Scorecard.load('sample_csvs/scorecard.csv', user, 'Loaded via seeds')

puts 'Loading P911Tf'
P911Tf.load('sample_csvs/p911_tf.csv', user, 'Loaded via seeds')

puts 'Loading P911Yr'
P911Yr.load('sample_csvs/p911_yr.csv', user, 'Loaded via seeds')

puts 'Loading Vsoc'
Vsoc.load('sample_csvs/vsoc.csv', user, 'Loaded via seeds')

puts 'Loading Sva'
Sva.load('sample_csvs/sva.csv', user, 'Loaded via seeds')

puts 'Loading Sec702'
Sec702.load('sample_csvs/sec702.csv', user, 'Loaded via seeds')

puts 'Loading Sec702School'
Sec702School.load('sample_csvs/sec702_school.csv', user, 'Loaded via seeds')

puts 'Loading Mou'
Mou.load('sample_csvs/mou.csv', user, 'Loaded via seeds', skip_lines: 1)

puts 'Loading Hcm'
Hcm.load('sample_csvs/hcm.csv', user, 'Loaded via seeds', skip_lines: 2)

puts 'Loading Settlement'
Settlement.load('sample_csvs/settlement.csv', user, 'Loaded via seeds')

puts 'Loading IpedsIc'
IpedsIc.load('sample_csvs/ipeds_ic.csv', user, 'Loaded via seeds')

puts 'Loading IpedsIcAy'
IpedsIcAy.load('sample_csvs/ipeds_ic_ay.csv', user, 'Loaded via seeds')

puts 'Loading IpedsIcPy'
IpedsIcPy.load('sample_csvs/ipeds_ic_py.csv', user, 'Loaded via seeds')

puts 'Loading IpedsHd'
IpedsHd.load('sample_csvs/ipeds_hd.csv', user, 'Loaded via seeds')

puts 'Loading Complaint'
Complaint.load('sample_csvs/complaint.csv', user, 'Loaded via seeds', skip_lines: 7)

puts 'Loading Outcome'
Outcome.load('sample_csvs/outcome.csv', user, 'Loaded via seeds')

puts 'Building Institutions'
version = InstitutionBuilder.run(user)

puts "Setting version: #{version.number} as production"
Version.create(user: user, number: version.number, production: true)

puts "Done ... Woo Hoo!"
