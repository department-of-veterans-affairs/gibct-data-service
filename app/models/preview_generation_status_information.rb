# frozen_string_literal: true

class PreviewGenerationStatusInformation < ApplicationRecord
  # Statuses are generated during GeneratePreviewJob. Because Solid Queue wraps jobs in db transactions,
  # specify primary db connection outside of job transaction so statuses can be polled by FE
  establish_connection :primary
end
