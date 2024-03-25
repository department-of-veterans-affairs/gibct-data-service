# frozen_string_literal: true

class VrrapProvider < ImportableRecord
  CSV_CONVERTER_INFO = {
    'schoolname' => { column: :school_name, converter: Converters::FacilityCodeConverter },
    'facilitycode' => { column: :facility_code, converter: Converters::BaseConverter },
    'programs' => { column: :programs, converter: Converters::BaseConverter },
    'vaco_approved/disapproved' => { column: :vaco, converter: Converters::BooleanConverter },
    'address' => { column: :address, converter: Converters::BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :vaco, inclusion: { in: [true, false], display_values: %w[Approved Disapproved] }
end
