# frozen_string_literal: true

class AccreditationRecord < ImportableRecord
  belongs_to(:accreditation_institute_campus, foreign_key: 'dapip_id', primary_key: :dapip_id,
                                              inverse_of: :accreditation_records)
  # Added the optional parameter because AccreditationRecords  can be created without an accreditation_type_keyword.
  # Rails 7 seems to enforce this more strictly. At least during rspec tests.
  belongs_to(:accreditation_type_keyword, inverse_of: :accreditation_records, optional: true)

  CSV_CONVERTER_INFO = {
    'dapipid' => { column: :dapip_id, converter: Converters::NumberConverter },
    'agencyid' => { column: :agency_id, converter: Converters::NumberConverter },
    'agencyname' => { column: :agency_name, converter: Converters::InstitutionConverter },
    'programid' => { column: :program_id, converter: Converters::NumberConverter },
    'programname' => { column: :program_name, converter: Converters::BaseConverter },
    'sequentialid' => { column: :sequential_id, converter: Converters::NumberConverter },
    'initialdateflag' => { column: :initial_date_flag, converter: Converters::BaseConverter },
    'accreditationdate' => { column: :accreditation_date, converter: Converters::DateConverter },
    'accreditationstatus' => { column: :accreditation_status, converter: Converters::BaseConverter },
    'reviewdate' => { column: :review_date, converter: Converters::DateConverter },
    'departmentdescription' => { column: :department_description, converter: Converters::BaseConverter },
    'accreditationenddate' => { column: :accreditation_end_date, converter: Converters::DateConverter },
    'endingactionid' => { column: :ending_action_id, converter: Converters::NumberConverter }
  }.freeze

  validates :dapip_id, presence: true
  validates :agency_id, presence: true
  validates :agency_name, presence: true
  validates :program_id, presence: true
  validates :program_name, presence: true

  delegate :accreditation_type, to: :accreditation_type_keyword, allow_nil: true

  after_initialize :set_accreditation_type

  def type_of_accreditation
    accreditation_type_keyword&.accreditation_type
  end

  private

  def set_accreditation_type
    return if agency_name.blank?

    # The order matters. regional, national, hybrid - stop at the first match.
    AccreditationTypeKeyword::ACCREDITATION_TYPES.each do |accreditation_type|
      find_accreditation_type(AccreditationTypeKeyword.where(accreditation_type: accreditation_type))
      break if accreditation_type_keyword
    end
  end

  def find_accreditation_type(accreditation_type_keywords)
    accreditation_type_keywords.each do |atk|
      next unless agency_name.downcase.include?(atk.keyword_match)

      self.accreditation_type_keyword = atk
      break
    end
  end
end
