# frozen_string_literal: true
module Savable
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_uniqueness
  end

  # Rely on postgres to enforce uniqueness, eliminates a query to determine if column
  # is not unique.
  def save_for_bulk_insert
    self.skip_uniqueness = true
    save
  end

  class_methods do
    # Override to provide custom row validation before model instance is created.
    def permit_csv_row_before_save(row = true)
      row
    end
  end
end
