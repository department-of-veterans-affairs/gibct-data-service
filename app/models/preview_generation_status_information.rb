# frozen_string_literal: true

class PreviewGenerationStatusInformation < ApplicationRecord
  establish_connection :primary unless Rails.env.test?
end
