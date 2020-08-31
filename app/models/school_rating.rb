# frozen_string_literal: true

class SchoolRating < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'ranker id' => { column: :ranker_id, converter: BaseConverter },
    'overall experience' => { column: :overall_experience, converter: RankingConverter },
    'quality of classes' => { column: :quality_of_classes, converter: RankingConverter },
    'online instruction' => { column: :online_instruction, converter: RankingConverter },
    'job preparation' => { column: :job_preparation, converter: RankingConverter },
    'gi bill support' => { column: :gi_bill_support, converter: RankingConverter },
    'veteran community' => { column: :veteran_community, converter: RankingConverter },
    'marketing practices' => { column: :marketing_practices, converter: RankingConverter },
    'ranked on' => { column: :ranked_on, converter: BaseConverter }
  }.freeze

  validates :facility_code, :ranked_on, presence: true
  validates_with SchoolCertifyingOfficialValidator, on: :after_import
end
