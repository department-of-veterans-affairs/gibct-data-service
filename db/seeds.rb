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

puts "Done ... Woo Hoo!"
