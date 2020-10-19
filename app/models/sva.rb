# frozen_string_literal: true

class Sva < ImportableRecord
  CSV_CONVERTER_INFO = {
    'id' => { column: :csv_id, converter: NumberConverter },
    'school' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'ipeds_code' => { column: :ipeds_code, converter: BaseConverter },
    'website' => { column: :student_veteran_link, converter: BaseConverter },
    'ipeds_6' => { column: :cross, converter: CrossConverter },
    'sva_yes' => { column: :sva_yes, converter: BaseConverter }
  }.freeze

  validates :cross, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.student_veteran_link = nil if student_veteran_link == 'http://www.studentveterans.org'
  end
end
