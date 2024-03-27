# frozen_string_literal: true

class AccreditationTypeKeyword < ApplicationRecord
  has_many(:accreditation_records, inverse_of: :accreditation_type_keyword, dependent: :nullify)

  # Order matters. The user should be asked about where to add any new ones.
  ACCREDITATION_TYPES = %w[regional national hybrid].freeze

  before_validation :downcase_keyword

  validates :accreditation_type, presence: true
  validates :accreditation_type, inclusion: { in: ACCREDITATION_TYPES }
  validates :keyword_match, presence: true
  validates :keyword_match, uniqueness: { scope: :accreditation_type }

  private

  def downcase_keyword
    keyword_match.downcase! if keyword_match.present?
  end
end
