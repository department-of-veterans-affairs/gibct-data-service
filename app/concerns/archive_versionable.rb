# frozen_string_literal: true

module ArchiveVersionable
  extend ActiveSupport::Concern

  included do
    extend Common::Shared
    extend Common::Exporter

    scope :circa, ->(year) { where(version: Version.latest_from_year(year)) }
    scope :over_the_years, ->(start_year, end_year) do
      where(version: Version.latest_from_year_range(start_year, end_year))
    end
  end

  module ClassMethods
    def earliest_available_year
      record = where.not(version_id: nil)
                    .order(:created_at)
                    .first
      return nil if record.blank?

      record.created_at.year
    end
  end
end
