# frozen_string_literal: true

module ArchiveVersionable
  extend ActiveSupport::Concern

  module ClassMethods
    def circa(year)
      klass_from(year).where(version: Version.latest_from_year(year))
    end

    # start_year and end_year are inclusive
    def over_the_years(start_year = earliest_available_year, end_year = Time.now.year)
      validate_years(start_year, end_year)
      return {} if earliest_available_year.nil?

      almanac = {}
      end_year.downto(start_year) do |year|
        records = circa(year)
        version = records.first.version
        almanac[year] = {
          records: records,
          meta: {
            updated_by: version.user.email,
            date: version.completed_at
          }
        }
      end
      almanac
    end

    def earliest_available_year
      record = where.not(version_id: nil)
                    .order(:created_at)
                    .first
      return nil unless record.present?
      
      record.created_at.year
    end

    private

    def klass_from(year)
      return self unless year == Time.now.year

      raise NotImplementedError, "#{name} must define SOURCE_TABLE" unless defined?(self::SOURCE_TABLE)

      self::SOURCE_TABLE
    end

    def validate_years(start_year, end_year)
      unless [start_year, end_year].all? { |year| year.is_a?(Integer) }
        raise ArgumentError, 'Must provide a valid year'
      end
      
      raise ArgumentError, 'Start year must be less than or equal to end year' if start_year > end_year
    end
  end
end
