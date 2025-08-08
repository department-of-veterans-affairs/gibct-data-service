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

  validates :raw_degree_level, presence: true, uniqueness: true
  validate :only_valid_translations

  before_validation :downcase_raw_degree_level

  protected

  def downcase_raw_degree_level
    self.raw_degree_level = raw_degree_level&.downcase
  end

  def only_valid_translations
    errors.add(:translations, 'Must not be emtpy') if translations.empty?
    errors.add(:translations, 'Invalid translations') if translations.size != translations.filter{|t| VALID_DEGREE_LEVELS.include?(t)}.size
  end
end
