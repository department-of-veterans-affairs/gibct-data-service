# frozen_string_literal: true

class VrrapProvider < ImportableRecord
  CSV_CONVERTER_INFO = {
    'schoolname' => { column: :school_name, converter: FacilityCodeConverter },
    'facilitycode' => { column: :facility_code, converter: BaseConverter },
    'programs' => { column: :programs, converter: BaseConverter },
    'vaco_approved/disapproved' => { column: :vaco, converter: BooleanConverter },
    'address' => { column: :address, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :vaco, inclusion: { in: [true, false], display_values: %w[Approved Disapproved] }
end
