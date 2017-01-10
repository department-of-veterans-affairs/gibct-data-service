# frozen_string_literal: true
class Accreditation < ActiveRecord::Base
  include Loadable, Exportable

  MAP = {
    'institution_id' => { institution_id: BaseConverter },
    'institution_name' => { institution_name: InstitutionConverter },
    'institution_address' => { institution_address: BaseConverter },
    'institution_city' => { institution_city: BaseConverter },
    'institution_state' => { institution_state: BaseConverter },
    'institution_zip' => { institution_zip: BaseConverter },
    'institution_phone' => { institution_phone: BaseConverter },
    'institution_opeid' => { ope: OpeConverter },
    'institution_ipeds_unitid' => { institution_ipeds_unitid: CrossConverter },
    'institution_web_address' => { institution_web_address: BaseConverter },
    'campus_id' => { campus_id: BaseConverter },
    'campus_name' => { campus_name: InstitutionConverter },
    'campus_address' => { campus_address: BaseConverter },
    'campus_city' => { campus_city: BaseConverter },
    'campus_state' => { campus_state: BaseConverter },
    'campus_zip' => { campus_zip: BaseConverter },
    'campus_ipeds_unitid' => { campus_ipeds_unitid: CrossConverter },
    'accreditation_type' => { accreditation_type: BaseConverter },
    'agency_name' => { agency_name: BaseConverter },
    'agency_status' => { agency_status: BaseConverter },
    'program_name' => { program_name: BaseConverter },
    'accreditation_status' => { accreditation_csv_status: BaseConverter },
    'accreditation_date_type' => { accreditation_date_type: BaseConverter },
    'periods' => { periods: BaseConverter },
    'last action' => { accreditation_status: BaseConverter }
  }.freeze

  # The ACCREDITATIONS hash maps accreditation types (Regional, National, or
  # Hybrid) to substrings in the name of the accrediting body. So, for example,
  # if the accrediting agency is the "New England Medical Association", then
  # the accreditation is 'Regional'.
  ACCREDITATIONS = {
    'REGIONAL' => ['middle', 'new england', 'north central', 'southern', 'western'],
    'NATIONAL' => ['career schools', 'continuing education', 'independent colleges',
                   'biblical', 'occupational', 'distance', 'new york', 'transnational'],
    'HYBRID' => ['acupuncture', 'nursing', 'health education', 'liberal', 'legal',
                 'funeral', 'osteopathic', 'pediatric', 'theological', 'massage', 'radiologic',
                 'midwifery', 'montessori', 'career arts', 'design', 'dance', 'music',
                 'theatre', 'chiropractic']
  }.freeze

  # LAST_ACTIONS are an array of strings that refer to changes to accreditation
  # from which caution flags are derived ('show cause' and 'probation').
  LAST_ACTIONS = [
    'resigned', 'terminated', 'closed by institution', 'probation',
    'show cause', 'expired', 'no longer recognized', 'accredited',
    'resigned under show cause', 'denied full accreditation', 'pre-accredited'
  ].freeze

  # ACCREDITATION_TYPES are used to detail accreditation types in the CSV.
  # Only INSTITUTIONAL accreditation types are recognized by the DS and GIBCT.
  ACCREDITATION_TYPES = ['INSTITUTIONAL', 'SPECIALIZED', 'INTERNSHIP/RESIDENCY'].freeze

  before_validation :derive_dependent_columns

  def derive_dependent_columns
    self.cross = to_cross
    self.ope6 = Ope6Converter.convert(ope)
    self.institution = to_institution

    true
  end

  def to_institution
    campus_name || institution_name
  end

  def to_cross
    campus_ipeds_unitid || institution_ipeds_unitid
  end
end
