# frozen_string_literal: true

class AccreditationRecord < ApplicationRecord
  include CsvHelper

  belongs_to(:accreditation_institute_campus, foreign_key: 'dapip_id', primary_key: :dapip_id,
                                              inverse_of: :accreditation_records)

  CSV_CONVERTER_INFO = {
    'dapipid' => { column: :dapip_id, converter: NumberConverter },
    'agencyid' => { column: :agency_id, converter: NumberConverter },
    'agencyname' => { column: :agency_name, converter: InstitutionConverter },
    'programid' => { column: :program_id, converter: NumberConverter },
    'programname' => { column: :program_name, converter: BaseConverter },
    'sequentialid' => { column: :sequential_id, converter: NumberConverter },
    'initialdateflag' => { column: :initial_date_flag, converter: BaseConverter },
    'accreditationdate' => { column: :accreditation_date, converter: DateConverter },
    'accreditationstatus' => { column: :accreditation_status, converter: BaseConverter },
    'reviewdate' => { column: :review_date, converter: DateConverter },
    'departmentdescription' => { column: :department_description, converter: BaseConverter },
    'accreditationenddate' => { column: :accreditation_end_date, converter: DateConverter },
    'endingactionid' => { column: :ending_action_id, converter: NumberConverter }
  }.freeze

  # The ACCREDITATIONS hash maps accreditation types (Regional, National, or
  # Hybrid) to substrings in the name of the accrediting body. So, for example,
  # if the accrediting agency is the "New England Medical Association", then
  # the accreditation is 'Regional'.
  ACCREDITATIONS = {
    'regional' => [/middle/i, /new england/i, /north central/i, /southern/i, /western/i,
                   /higher learning commission/i, /wasc/i],
    'national' => [/career schools/i, /continuing education/i, /independent colleges/i,
                   /biblical/i, /occupational/i, /distance/i, /new york/i, /transnational/i],
    'hybrid' => [/acupuncture/i, /nursing/i, /health education/i, /liberal/i, /legal/i,
                 /funeral/i, /osteopathic/i, /pediatric/i, /theological/i, /massage/i, /radiologic/i,
                 /midwifery/i, /montessori/i, /career arts/i, /design/i, /dance/i, /music/i,
                 /theatre/i, /chiropractic/i]
  }.freeze

  validates :dapip_id, presence: true
  validates :agency_id, presence: true
  validates :agency_name, presence: true
  validates :program_id, presence: true
  validates :program_name, presence: true

  after_initialize :set_accreditation_type

  private

  def set_accreditation_type
    self.accreditation_type = to_accreditation_type
  end

  def to_accreditation_type
    return if agency_name.blank?

    ACCREDITATIONS.each_pair do |type, regexp_array|
      return type if regexp_array.find { |regexp| agency_name.match(regexp) }
    end

    nil
  end
end
