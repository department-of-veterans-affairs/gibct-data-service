# frozen_string_literal: true

class CalculatorConstantVersionsArchive < ApplicationRecord
  extend Common::Shared
  extend Common::Exporter

  belongs_to :version

  # Year versioning first implemented for CalculatorConstants
  EARLIEST_AVAILABLE_YEAR = 2025
  SOURCE_TABLE = 'calculator_constant_versions'

  class << self
    # Current year yields zero results because latest from current year has yet to be archived
    def circa(year)
      version = Version.latest_from_year(year)
      return CalculatorConstantVersionsArchive.none if version.nil?

      CalculatorConstantVersionsArchive.where(version_id: version.id)
    end

    # Inclusive of start and end year
    def over_the_years(start_year, end_year)
      validate_year_range(start_year, end_year)
      # Adjust start and end year if they are outside bounds of existing records
      start_year = EARLIEST_AVAILABLE_YEAR if start_year < EARLIEST_AVAILABLE_YEAR
      end_year = Time.zone.now.year if end_year > Time.zone.now.year

      version_ids = (start_year..end_year).map { |year| Version.latest_from_year(year) }
                                          .compact
                                          .pluck(:id)
      CalculatorConstantVersionsArchive.where(version_id: version_ids)
    end

    def source_klass
      SOURCE_TABLE.classify.constantize
    end

    private

    def validate_year_range(start_year, end_year)
      raise ArgumentError, 'Must provide a valid year' unless [start_year, end_year].all? { |y| y.is_a?(Integer) }
      raise ArgumentError, 'Start year must be less than or equal to end year' if start_year > end_year
    end
  end
end
