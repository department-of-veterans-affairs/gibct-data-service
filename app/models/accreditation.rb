# frozen_string_literal: true

class Accreditation < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'institution_id' => { column: :institution_id, converter: NumberConverter },
    'institution_name' => { column: :institution_name, converter: InstitutionConverter },
    'institution_address' => { column: :institution_address, converter: BaseConverter },
    'institution_city' => { column: :institution_city, converter: BaseConverter },
    'institution_state' => { column: :institution_state, converter: BaseConverter },
    'institution_zip' => { column: :institution_zip, converter: BaseConverter },
    'institution_phone' => { column: :institution_phone, converter: BaseConverter },
    'institution_opeid' => { column: :ope, converter: OpeConverter },
    'institution_ipeds_unitid' => { column: :institution_ipeds_unitid, converter: CrossConverter },
    'institution_web_address' => { column: :institution_web_address, converter: BaseConverter },
    'campus_id' => { column: :campus_id, converter: NumberConverter },
    'campus_name' => { column: :campus_name, converter: InstitutionConverter },
    'campus_address' => { column: :campus_address, converter: BaseConverter },
    'campus_city' => { column: :campus_city, converter: BaseConverter },
    'campus_state' => { column: :campus_state, converter: BaseConverter },
    'campus_zip' => { column: :campus_zip, converter: BaseConverter },
    'campus_ipeds_unitid' => { column: :campus_ipeds_unitid, converter: CrossConverter },
    'accreditation_type' => { column: :csv_accreditation_type, converter: DowncaseConverter },
    'agency_name' => { column: :agency_name, converter: BaseConverter },
    'agency_status' => { column: :agency_status, converter: BaseConverter },
    'program_name' => { column: :program_name, converter: BaseConverter },
    'accreditation_status' => { column: :accreditation_csv_status, converter: BaseConverter },
    'accreditation_date_type' => { column: :accreditation_date_type, converter: BaseConverter },
    'periods' => { column: :periods, converter: DowncaseConverter },
    'last action' => { column: :accreditation_status, converter: DisplayConverter }
  }.freeze

  # The ACCREDITATIONS hash maps accreditation types (Regional, National, or
  # Hybrid) to substrings in the name of the accrediting body. So, for example,
  # if the accrediting agency is the "New England Medical Association", then
  # the accreditation is 'Regional'.
  ACCREDITATIONS = {
    'regional' => [/middle/i, /new england/i, /north central/i, /southern/i, /western/i],
    'national' => [/career schools/i, /continuing education/i, /independent colleges/i,
                   /biblical/i, /occupational/i, /distance/i, /new york/i, /transnational/i],
    'hybrid' => [/acupuncture/i, /nursing/i, /health education/i, /liberal/i, /legal/i,
                 /funeral/i, /osteopathic/i, /pediatric/i, /theological/i, /massage/i, /radiologic/i,
                 /midwifery/i, /montessori/i, /career arts/i, /design/i, /dance/i, /music/i,
                 /theatre/i, /chiropractic/i]
  }.freeze

  # LAST_ACTIONS are an array of strings that refer to changes to accreditation
  # from which caution flags are derived ('show cause' and 'probation').
  LAST_ACTIONS = [
    'Resigned', 'Terminated', 'Closed By Institution', 'Probation',
    'Show Cause', 'Expired', 'No Longer Recognized', 'Accredited',
    'Resigned Under Show Cause', 'Denied Full Accreditation', 'Pre-Accredited'
  ].freeze

  # CSV_ACCREDITATION_TYPES are used to detail accreditation types in the CSV.
  # Only INSTITUTIONAL accreditation types are recognized by the DS and GIBCT.
  CSV_ACCREDITATION_TYPES = ['institutional', 'specialized', 'internship/residency'].freeze

  validates :agency_name, presence: true
  validates :accreditation_status, inclusion: { in: LAST_ACTIONS }, allow_blank: true
  validates :csv_accreditation_type, inclusion: { in: CSV_ACCREDITATION_TYPES }, allow_blank: false

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.cross = to_cross
    self.ope6 = Ope6Converter.convert(ope)
    self.institution = to_institution
    self.accreditation_type = to_accreditation_type
  end

  def to_institution
    campus_name || institution_name
  end

  def to_cross
    campus_ipeds_unitid || institution_ipeds_unitid
  end

  def to_accreditation_type
    return if agency_name.blank?

    ACCREDITATIONS.each_pair do |type, regexp_array|
      return type if regexp_array.find { |regexp| agency_name.match(regexp) }
    end

    nil
  end
end
