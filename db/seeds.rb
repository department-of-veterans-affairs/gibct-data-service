puts 'Destroy previous users ... '
User.destroy_all

puts 'Add new users ... '
User.create(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PW'])

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

puts 'Loading CSVs, why not go get a nice cup of coffee while you wait? ... '
puts 'Loading Weam'
Weam.load('sample_csvs/weam.csv')

puts 'Loading Crosswalk'
Crosswalk.load('sample_csvs/crosswalk.csv')

puts 'Loading EightKey'
EightKey.load('sample_csvs/eight_key.csv', skip_lines: 1)

puts 'Loading Accreditation'
Accreditation.load('sample_csvs/accreditation.csv')

puts 'Loading Scorecard'
Scorecard.load('sample_csvs/scorecard.csv')

puts 'Loading P911Tf'
P911Tf.load('sample_csvs/p911_tf.csv')

puts 'Loading P911Yr'
P911Yr.load('sample_csvs/p911_yr.csv')

puts 'Loading Vsoc'
Vsoc.load('sample_csvs/vsoc.csv')

puts 'Loading Sva'
Sva.load('sample_csvs/sva.csv')

puts 'Loading Sec702'
Sec702.load('sample_csvs/sec702.csv')

puts 'Loading Sec702School'
Sec702School.load('sample_csvs/sec702_school.csv')

puts 'Loading Mou'
Mou.load('sample_csvs/mou.csv', skip_lines: 1)

puts 'Loading Hcm'
Hcm.load('sample_csvs/hcm.csv', skip_lines: 2)

puts 'Loading Settlement'
Settlement.load('sample_csvs/settlement.csv')

puts 'Loading IpedsIc'
IpedsIc.load('sample_csvs/ipeds_ic.csv')

puts 'Loading IpedsIcAy'
IpedsIcAy.load('sample_csvs/ipeds_ic_ay.csv')

puts 'Loading IpedsIcPy'
IpedsIcPy.load('sample_csvs/ipeds_ic_py.csv')

puts 'Loading IpedsHd'
IpedsHd.load('sample_csvs/ipeds_hd.csv')

puts 'Loading Complaint'
Complaint.load('sample_csvs/complaint.csv', skip_lines: 7)

puts 'Loading Outcome'
Outcome.load('sample_csvs/outcome.csv')

puts "Done ... Woo Hoo!"
