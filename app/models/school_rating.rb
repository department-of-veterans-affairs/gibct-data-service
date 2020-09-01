# frozen_string_literal: true

class SchoolRating < ApplicationRecord
  include CsvHelper

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
    'rated on' => { column: :rated_on, converter: DateTimeConverter }
  }.freeze

  validates :facility_code, :rater_id, :rated_on, presence: true
end
