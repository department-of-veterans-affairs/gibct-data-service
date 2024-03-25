# frozen_string_literal: true

class Sva < ImportableRecord
  CSV_CONVERTER_INFO = {
    'id' => { column: :csv_id, converter: Converters::NumberConverter },
    'school' => { column: :institution, converter: Converters::InstitutionConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'state' => { column: :state, converter: Converters::BaseConverter },
    'ipeds_code' => { column: :ipeds_code, converter: Converters::BaseConverter },
    'website' => { column: :student_veteran_link, converter: Converters::BaseConverter },
    'ipeds_6' => { column: :cross, converter: Converters::CrossConverter },
    'sva_yes' => { column: :sva_yes, converter: Converters::BaseConverter }
  }.freeze

  validates :cross, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.student_veteran_link = nil if student_veteran_link == 'http://www.studentveterans.org'
  end
end
