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
  before_validation :strip_empty_translations

  def self.generate_guesses_for_unmapped_values
    unmapped_degree_levels = YellowRibbonProgramSource
                             .joins('left join yellow_ribbon_degree_level_translations on lower(degree_level) = raw_degree_level')
                             .where(yellow_ribbon_degree_level_translations: { id: nil })
                             .pluck(:degree_level)

    unmapped_degree_levels.each do |degree_level|
      create(raw_degree_level: degree_level, translations: guess_translations(degree_level))
    end
  end

  def self.guess_translations(raw_string)
    result = []

    {
      'All' => [],
      'Certificate' => [/certif/i],
      'Associates' => [/\bassoc/i, /\baas/i],
      'Bachelors' => [/bachel/i],
      'Undergraduate' => [/undergra/i],
      'Masters' => [/master/i],
      'Graduate' => [/\bgrad/i],
      'Doctoral' => [/doctor/i],
      'Other' => []
    }.each do |level, patterns|
      result.push(level) if patterns.any? { |pattern| pattern =~ raw_string }
    end

    result.push('Other') if result.empty?
    result
  end

  protected

  def downcase_raw_degree_level
    self.raw_degree_level = raw_degree_level&.downcase
  end

  def strip_empty_translations
    self.translations = translations.reject(&:empty?)
  end

  def only_valid_translations
    errors.add(:translations, 'Must not be emtpy') if translations.empty?
    errors.add(:translations, 'Invalid translations') if translations.size != translations.filter do |t|
                                                                                VALID_DEGREE_LEVELS.include?(t)
                                                                              end.size
  end
end
