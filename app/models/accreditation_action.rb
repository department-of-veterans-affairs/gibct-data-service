# frozen_string_literal: true

class AccreditationAction < ImportableRecord
  include AccreditationFetchUtils

  belongs_to(:accreditation_institute_campus, foreign_key: 'dapip_id', primary_key: :dapip_id,
                                              inverse_of: :accreditation_actions)

  CSV_CONVERTER_INFO = {
    'dapipid' => { column: :dapip_id, converter: NumberConverter },
    'agencyid' => { column: :agency_id, converter: NumberConverter },
    'agencyname' => { column: :agency_name, converter: InstitutionConverter },
    'programid' => { column: :program_id, converter: NumberConverter },
    'programname' => { column: :program_name, converter: BaseConverter },
    'sequentialid' => { column: :sequential_id, converter: NumberConverter },
    'actiondescription' => { column: :action_description, converter: BaseConverter },
    'actiondate' => { column: :action_date, converter: AccreditationDateTimeConverter },
    'justificationdescription' => { column: :justification_description, converter: BaseConverter },
    'justificationother' => { column: :justification_other, converter: BaseConverter },
    'enddate' => { column: :end_date, converter: BaseConverter }
  }.freeze

  PROBATIONARY_STATUSES = [
    "'Loss of Accreditation or Preaccreditation: Denial'",
    "'Loss of Accreditation or Preaccreditation: Lapse'",
    "'Loss of Accreditation or Preaccreditation: Other'",
    "'Probation or Equivalent or More Severe Status: Monitoring'",
    "'Probation or Equivalent or a More Severe Status: Other'",
    "'Probation or Equivalent or a More Severe Status: Probation'",
    "'Probation or Equivalent or a More Severe Status: Show Cause'",
    "'Probation or Equivalent or a More Severe Status: Warning'",
    "'Warning or Equivalent-Factors Affecting Academic Quality'"
  ].freeze

  RESTORATIVE_STATUSES = [
    "'Accreditation Reaffirmed:  Warning Removed'",
    "'Accreditation Reaffirmed: Probation Removed'",
    "'Accreditation Reinstated: Termination Overturned on Appeal'",
    "'Heightened Monitoring or Focused Review'",
    "'Removal of Monitoring Status'",
    "'Removal of Show Cause Status'",
    "'Renewal of Accreditation'",
    "'Stay Denial Pending Appeal'"
  ].freeze

  API_SOURCE = 'https://ope.ed.gov/dapip/#/download-data-files'

  validates :dapip_id, presence: true
  validates :agency_id, presence: true
  validates :agency_name, presence: true
  validates :program_id, presence: true
  validates :program_name, presence: true
  validates :action_description, presence: true
  validates :justification_description, presence: true
end
