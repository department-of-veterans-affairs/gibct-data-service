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
Weam.load('sample_csvs/weam.csv')
Upload.create(original_filename: 'weam.csv', csv_type: 'Weam', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Crosswalk'
Crosswalk.load('sample_csvs/crosswalk.csv')
Upload.create(original_filename: 'crosswalk.csv', csv_type: 'Crosswalk', comment: 'Seeds.', user: user, ok: true)

puts 'Loading EightKey'
EightKey.load('sample_csvs/eight_key.csv', skip_lines: 1)
Upload.create(original_filename: 'eight_key.csv', csv_type: 'EightKey', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Accreditation'
Accreditation.load('sample_csvs/accreditation.csv')
Upload.create(original_filename: 'accreditation.csv',
              csv_type: 'Accreditation', comment: 'Seeds.', user: user, ok: true)

puts 'Loading ArfGiBill'
ArfGiBill.load('sample_csvs/arf.csv')
Upload.create(original_filename: 'arf.csv', csv_type: 'ArfGiBill', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Scorecard'
Scorecard.load('sample_csvs/scorecard.csv')
Upload.create(original_filename: 'scorecard.csv', csv_type: 'Scorecard', comment: 'Seeds.', user: user, ok: true)

puts 'Loading P911Tf'
P911Tf.load('sample_csvs/p911_tf.csv')
Upload.create(original_filename: 'p911_tf.csv', csv_type: 'P911Tf', comment: 'Seeds.', user: user, ok: true)

puts 'Loading P911Yr'
P911Yr.load('sample_csvs/p911_yr.csv')
Upload.create(original_filename: 'p911_yr.csv', csv_type: 'P911Yr', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Vsoc'
Vsoc.load('sample_csvs/vsoc.csv')
Upload.create(original_filename: 'vsoc.csv', csv_type: 'Vsoc', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Sva'
Sva.load('sample_csvs/sva.csv')
Upload.create(filename: 'sva.csv', csv_type: 'Sva', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Sec702'
Sec702.load('sample_csvs/sec702.csv')
Upload.create(original_filename: 'sec702.csv', csv_type: 'Sec702', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Sec702School'
Sec702School.load('sample_csvs/sec702_school.csv')
Upload.create(original_filename: 'sec702_school.csv', csv_type: 'Sec702School', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Mou'
Mou.load('sample_csvs/mou.csv', skip_lines: 1)
Upload.create(original_filename: 'mou.csv', csv_type: 'Mou', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Hcm'
Hcm.load('sample_csvs/hcm.csv', skip_lines: 2)
Upload.create(original_filename: 'hcm.csv', csv_type: 'Hcm', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Settlement'
Settlement.load('sample_csvs/settlement.csv')
Upload.create(original_filename: 'settlement.csv', csv_type: 'Settlement', comment: 'Seeds.', user: user, ok: true)

puts 'Loading IpedsIc'
IpedsIc.load('sample_csvs/ipeds_ic.csv')
Upload.create(original_filename: 'ipeds_ic.csv', csv_type: 'IpedsIc', comment: 'Seeds.', user: user, ok: true)

puts 'Loading IpedsIcAy'
IpedsIcAy.load('sample_csvs/ipeds_ic_ay.csv')
Upload.create(original_filename: 'ipeds_ic_ay.csv', csv_type: 'IpedsIcAy', comment: 'Seeds.', user: user, ok: true)

puts 'Loading IpedsIcPy'
IpedsIcPy.load('sample_csvs/ipeds_ic_py.csv')
Upload.create(original_filename: 'ipeds_ic_py.csv', csv_type: 'IpedsIcPy', comment: 'Seeds.', user: user, ok: true)

puts 'Loading IpedsHd'
IpedsHd.load('sample_csvs/ipeds_hd.csv')
Upload.create(original_filename: 'ipeds_hd.csv', csv_type: 'IpedsHd', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Complaint'
Complaint.load('sample_csvs/complaint.csv', skip_lines: 7)
Upload.create(original_filename: 'complaint.csv', csv_type: 'Complaint', comment: 'Seeds.', user: user, ok: true)

puts 'Loading Outcome'
Outcome.load('sample_csvs/outcome.csv')
Upload.create(original_filename: 'outcome.csv', csv_type: 'Outcome', comment: 'Seeds.', user: user, ok: true)

puts 'Building Institutions'
version = InstitutionBuilder.run(user)

puts "Setting version: #{version.number} as production"
Version.create(user: user, number: version.number, production: true)

puts "Done ... Woo Hoo!"
