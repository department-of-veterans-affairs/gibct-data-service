# frozen_string_literal: true

class SchoolRating < ImportableRecord
  CSV_CONVERTER_INFO = {
    'rater_id' => { column: :rater_id, converter: BaseConverter },
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'overall_experience' => { column: :overall_experience, converter: SchoolRatingConverter },
    'quality_of_classes' => { column: :quality_of_classes, converter: SchoolRatingConverter },
    'online_instruction' => { column: :online_instruction, converter: SchoolRatingConverter },
    'job_preparation' => { column: :job_preparation, converter: SchoolRatingConverter },
    'gi_bill_support' => { column: :gi_bill_support, converter: SchoolRatingConverter },
    'veteran_community' => { column: :veteran_community, converter: SchoolRatingConverter },
    'marketing_practices' => { column: :marketing_practices, converter: SchoolRatingConverter },
    'rated_date' => { column: :rated_at, converter: BaseConverter }
  }.freeze

  validates :facility_code, :rater_id, :rated_at, presence: true
  validates :overall_experience, :quality_of_classes, :online_instruction, :job_preparation,
            :gi_bill_support, :veteran_community, :marketing_practices,
            numericality: true, allow_blank: true
end
