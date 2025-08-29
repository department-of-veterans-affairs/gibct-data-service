# frozen_string_literal: true

# TO-DO: Rename to VersionGenerationStatus
class PreviewGenerationStatusInformation < ApplicationRecord
  # Enables status records to be instantly committed inside GeneratePreviewJob transaction
  establish_connection :primary unless Rails.env.test?

  # TO-DO: Add timestamps to table
  def self.latest
    order(id: :asc).first
  end
end
