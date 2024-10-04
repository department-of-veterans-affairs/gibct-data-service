# frozen_string_literal: true

class Lce::Institution < ImportableRecord
  CSV_CONVERTER_INFO = {
    'ptcpnt_id' => { column: :ptcpnt_id, converter: Converters::NumberConverter },
    'name' => { column: :name, converter: Converters::BaseConverter },
    'abbreviated_name' => { column: :abbreviated_name, converter: Converters::BaseConverter },
    'physical_street' => { column: :physical_street, converter: Converters::BaseConverter },
    'physical_city' => { column: :physical_city, converter: Converters::BaseConverter },
    'physical_state' => { column: :physical_state, converter: Converters::BaseConverter },
    'physical_zip' => { column: :physical_zip, converter: Converters::BaseConverter },
    'physical_country' => { column: :physical_country, converter: Converters::BaseConverter },
    'mailing_street' => { column: :mailing_street, converter: Converters::BaseConverter },
    'mailing_city' => { column: :mailing_city, converter: Converters::BaseConverter },
    'mailing_state' => { column: :mailing_state, converter: Converters::BaseConverter },
    'mailing_zip' => { column: :mailing_zip, converter: Converters::BaseConverter },
    'mailing_country' => { column: :mailing_country, converter: Converters::BaseConverter },
    'phone' => { column: :phone, converter: Converters::BaseConverter },
    'web_address' => { column: :web_address, converter: Converters::BaseConverter }
  }.freeze

  has_many :exams, :class_name => 'Lce::Exam', :dependent => :destroy
  has_many :officials, :class_name => 'Lce::Official', :dependent => :destroy
  has_many :license_and_certs, :class_name => 'Lce::LicenseAndCert', :dependent => :destroy
end
