# frozen_string_literal: true

class YellowRibbonDegreeLevelTranslation < ApplicationRecord
  VALID_DEGREE_LEVELS = %w[
    All
    Certificate
    Associates
    Bachelors
    Undergraduate
    Masters
    Graduate
    Doctoral
    Other
  ].freeze

  validates :raw_degree_level, :translated_degree_level, presence: true
  validates :translated_degree_level, uniqueness: { scope: :raw_degree_level }, inclusion: { in: VALID_DEGREE_LEVELS }

  before_validation :downcase_raw_degree_level

  protected

  def downcase_raw_degree_level
    self.raw_degree_level = raw_degree_level&.downcase
  end
end
