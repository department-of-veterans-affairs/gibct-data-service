class AccreditationAction < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'dapipid' => { column: :dapip_id, converter: NumberConverter },
    'agencyid' => { column: :agency_id, converter: NumberConverter },
    'agencyname' => { column: :agency_name, converter: InstitutionConverter },
    'programid' => { column: :program_id, converter: NumberConverter },
    'programname' => { column: :program_name, converter: BaseConverter },
    'sequentialid' => { column: :sequential_id, converter: NumberConverter },
    'actiondescription' => { column: :action_description, converter: BaseConverter },
    'actiondate' => { column: :action_date, converter: DateConverter },
    'justificationdescription' => { column: :justification_description, converter: BaseConverter },
    'justificationother' => { column: :justification_other, converter: BaseConverter },
    'enddate' => { column: :end_date, converter: DateConverter }
  }.freeze

  ACCREDITATIONS = {
    'regional' => [/middle/i, /new england/i, /north central/i, /southern/i, /western/i],
    'national' => [/career schools/i, /continuing education/i, /independent colleges/i,
                   /biblical/i, /occupational/i, /distance/i, /new york/i, /transnational/i],
    'hybrid' => [/acupuncture/i, /nursing/i, /health education/i, /liberal/i, /legal/i,
                 /funeral/i, /osteopathic/i, /pediatric/i, /theological/i, /massage/i, /radiologic/i,
                 /midwifery/i, /montessori/i, /career arts/i, /design/i, /dance/i, /music/i,
                 /theatre/i, /chiropractic/i]
  }.freeze

  # after_initialize :derive_dependent_columns

  # def derive_dependent_columns
  #   self.accreditation_type = to_accreditation_type
  # end

  # def to_accreditation_type
  #   return if agency_name.blank?

  #   ACCREDITATIONS.each_pair do |type, regexp_array|
  #     return type if regexp_array.find { |regexp| agency_name.match(regexp) }
  #   end

  #   nil
  # end
end
