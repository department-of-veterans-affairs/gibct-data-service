# frozen_string_literal: true

class InStateTuitionPolicyUrl < ImportableRecord

  COLS_USED_IN_INSTITUTION = %i[in_state_tuition_information].freeze

    CSV_CONVERTER_INFO = {
        'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
        'in_state_tuition_information' => { column: :in_state_tuition_information, converter: BaseConverter }
      }.freeze
end