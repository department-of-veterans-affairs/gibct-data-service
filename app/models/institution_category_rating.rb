# frozen_string_literal: true

class InstitutionCategoryRating < ApplicationRecord
  RATING_CATEGORY_COLUMNS = %w[
    overall_experience
    quality_of_classes
    online_instruction
    job_preparation
    gi_bill_support
    veteran_community
    marketing_practices
  ].freeze

  belongs_to :institution
end
