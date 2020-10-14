# frozen_string_literal: true

class SchoolRating < ImportableRecord
  CSV_CONVERTER_INFO = {
    'rater id' => { column: :rater_id, converter: BaseConverter },
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'overall experience' => { column: :overall_experience, converter: SchoolRatingConverter },
    'quality of classes' => { column: :quality_of_classes, converter: SchoolRatingConverter },
    'online instruction' => { column: :online_instruction, converter: SchoolRatingConverter },
    'job preparation' => { column: :job_preparation, converter: SchoolRatingConverter },
    'gi bill support' => { column: :gi_bill_support, converter: SchoolRatingConverter },
    'veteran community' => { column: :veteran_community, converter: SchoolRatingConverter },
    'marketing practices' => { column: :marketing_practices, converter: SchoolRatingConverter },
    'rated date' => { column: :rated_at, converter: BaseConverter }
  }.freeze

  validates :facility_code, :rater_id, :rated_at, presence: true
  validates :overall_experience, :quality_of_classes, :online_instruction, :job_preparation,
            :gi_bill_support, :veteran_community, :marketing_practices,
            numericality: true, allow_blank: true
end
