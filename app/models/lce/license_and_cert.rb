class Lce::LicenseAndCert < ImportableRecord
  CSV_CONVERTER_INFO = {
    "name" => { column: :name, converter: Converters::BaseConverter },
    "fee" =>  { column: :amount, converter: Converters::NumberConverter },
  }.freeze

  belongs_to :institution, :class_name => 'Lce::Institution'
end
