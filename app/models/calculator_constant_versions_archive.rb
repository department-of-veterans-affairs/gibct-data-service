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

    # TO-DO: This logic can be simplified when it's 2026
    # Inclusive of start and end year
    def over_the_years(start_year, end_year)
      return CalculatorConstantVersionsArchive.none if earliest_available_year.nil?

      validate_year_range(start_year, end_year)
      # Adjust start and end year if they are outside bounds of existing records
      start_year = earliest_available_year if start_year < earliest_available_year
      end_year = Time.zone.now.year if end_year >= Time.zone.now.year

      versions = (start_year..end_year).map { |y| Version.latest_from_year(y) }.compact
      CalculatorConstantVersionsArchive.where(version_id: versions.pluck(:id))
    end

    # TO-DO: This logic can be simplified when it's 2026
    # Allow earliest available year to be overwritten for dev/test/staging
    def earliest_available_year
      earliest = if production?
                   EARLIEST_AVAILABLE_YEAR
                 else
                   record = CalculatorConstantVersionsArchive.where.not(version_id: nil)
                                                             .order(:created_at)
                                                             .first
                   record&.created_at&.year
                 end

      # Return nil if still 2025
      earliest unless earliest.nil? || earliest <= EARLIEST_AVAILABLE_YEAR
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
