# frozen_string_literal: true

# TODO: remove when we write new ratings code
class InstitutionCategoryRating < ApplicationRecord
  RATING_CATEGORY_COLUMNS = %w[
    overall_experience
    gi_bill_support
    veteran_community
    quality_of_classes
  ].freeze

  belongs_to :institution
end
