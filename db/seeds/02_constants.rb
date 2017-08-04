
puts 'Creating sample constants'
constants = {
  'TFCAP' => 22805.34,
  'AVGBAH' => 1681,
  'BSCAP' => 1000,
  'BSOJTMONTH' => 83,
  'FLTTFCAP' => 13031.61,
  'CORRESPONDTFCAP' => 11076.86,
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
  'AVERETENTIONRATE' => 67.7,
  'AVEGRADRATE' => 42.3,
  'AVESALARY' => 33_400,
  'AVEREPAYMENTRATE' => 67.9
# }.map { |k,v| {name: k, float_value: v} }
}.each_pair do |name, value|
  rec = CalculatorConstant.find_or_create_by(name: name).update!(float_value: value)
end
