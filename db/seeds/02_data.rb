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

puts 'Loading CSVs, why not go get a nice cup of coffee while you wait? ... '
puts 'Loading Weam'
Weam.delete_all
Weam.load('sample_csvs/weam.csv', user)

puts 'Loading Crosswalk'
Crosswalk.delete_all
Crosswalk.load('sample_csvs/crosswalk.csv', user)

puts 'Loading EightKey'
EightKey.delete_all
EightKey.load('sample_csvs/eight_key.csv', user, '', skip_lines: 1)

puts 'Loading Accreditation'
Accreditation.delete_all
Accreditation.load('sample_csvs/accreditation.csv', user)

puts 'Loading ArfGiBill'
ArfGiBill.delete_all
ArfGiBill.load('sample_csvs/arf.csv', user)

puts 'Loading Scorecard'
Scorecard.delete_all
Scorecard.load('sample_csvs/scorecard.csv', user)

puts 'Loading P911Tf'
P911Tf.delete_all
P911Tf.load('sample_csvs/p911_tf.csv', user)

puts 'Loading P911Yr'
P911Yr.delete_all
P911Yr.load('sample_csvs/p911_yr.csv', user)

puts 'Loading Vsoc'
Vsoc.delete_all
Vsoc.load('sample_csvs/vsoc.csv', user)

puts 'Loading Sva'
Sva.delete_all
Sva.load('sample_csvs/sva.csv', user)

puts 'Loading Sec702'
Sec702.delete_all
Sec702.load('sample_csvs/sec702.csv', user)

puts 'Loading Sec702School'
Sec702School.delete_all
Sec702School.load('sample_csvs/sec702_school.csv', user)

puts 'Loading Mou'
Mou.delete_all
Mou.load('sample_csvs/mou.csv', user, '', skip_lines: 1)

puts 'Loading Hcm'
Hcm.delete_all
Hcm.load('sample_csvs/hcm.csv', user, '', skip_lines: 2)

puts 'Loading Settlement'
Settlement.delete_all
Settlement.load('sample_csvs/settlement.csv', user)

puts 'Loading IpedsIc'
IpedsIc.delete_all
IpedsIc.load('sample_csvs/ipeds_ic.csv', user)

puts 'Loading IpedsIcAy'
IpedsIcAy.delete_all
IpedsIcAy.load('sample_csvs/ipeds_ic_ay.csv', user)

puts 'Loading IpedsIcPy'
IpedsIcPy.delete_all
IpedsIcPy.load('sample_csvs/ipeds_ic_py.csv', user)

puts 'Loading IpedsHd'
IpedsHd.delete_all
IpedsHd.load('sample_csvs/ipeds_hd.csv', user)

puts 'Loading Complaint'
Complaint.delete_all
Complaint.load('sample_csvs/complaint.csv', user, '', skip_lines: 7)

puts 'Loading Outcome'
Outcome.delete_all
Outcome.load('sample_csvs/outcome.csv', user)

puts 'Building Institutions'
InstitutionBuilder.run(user)

puts "Done ... Woo Hoo!"
