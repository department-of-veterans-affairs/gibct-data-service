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
Weam.delete_all
Weam.load('sample_csvs/weam.csv')

puts 'Loading Crosswalk'
Crosswalk.delete_all
Crosswalk.load('sample_csvs/crosswalk.csv')

puts 'Loading EightKey'
EightKey.delete_all
EightKey.load('sample_csvs/eight_key.csv', skip_lines: 1)

puts 'Loading Accreditation'
Accreditation.delete_all
Accreditation.load('sample_csvs/accreditation.csv')

puts 'Loading ArfGiBill'
ArfGiBill.delete_all
ArfGiBill.load('sample_csvs/arf.csv')

puts 'Loading Scorecard'
Scorecard.delete_all
Scorecard.load('sample_csvs/scorecard.csv')

puts 'Loading P911Tf'
P911Tf.delete_all
P911Tf.load('sample_csvs/p911_tf.csv')

puts 'Loading P911Yr'
P911Yr.delete_all
P911Yr.load('sample_csvs/p911_yr.csv')

puts 'Loading Vsoc'
Vsoc.delete_all
Vsoc.load('sample_csvs/vsoc.csv')

puts 'Loading Sva'
Sva.delete_all
Sva.load('sample_csvs/sva.csv')

puts 'Loading Sec702'
Sec702.delete_all
Sec702.load('sample_csvs/sec702.csv')

puts 'Loading Sec702School'
Sec702School.delete_all
Sec702School.load('sample_csvs/sec702_school.csv')

puts 'Loading Mou'
Mou.delete_all
Mou.load('sample_csvs/mou.csv', skip_lines: 1)

puts 'Loading Hcm'
Hcm.delete_all
Hcm.load('sample_csvs/hcm.csv', skip_lines: 2)

puts 'Loading Settlement'
Settlement.delete_all
Settlement.load('sample_csvs/settlement.csv')

puts 'Loading IpedsIc'
IpedsIc.delete_all
IpedsIc.load('sample_csvs/ipeds_ic.csv')

puts 'Loading IpedsIcAy'
IpedsIcAy.delete_all
IpedsIcAy.load('sample_csvs/ipeds_ic_ay.csv')

puts 'Loading IpedsIcPy'
IpedsIcPy.delete_all
IpedsIcPy.load('sample_csvs/ipeds_ic_py.csv')

puts 'Loading IpedsHd'
IpedsHd.delete_all
IpedsHd.load('sample_csvs/ipeds_hd.csv')

puts 'Loading Complaint'
Complaint.delete_all
Complaint.load('sample_csvs/complaint.csv', skip_lines: 7)

puts 'Loading Outcome'
Outcome.delete_all
Outcome.load('sample_csvs/outcome.csv')

puts 'Building Institutions'
InstitutionBuilder.run(User.first)

Version.update(1, production: true)

puts "Done ... Woo Hoo!"
