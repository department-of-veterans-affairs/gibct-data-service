# frozen_string_literal: true

class VersionedSchoolCertifyingOfficial < ApplicationRecord
  VALID_PRIORITY_VALUES = %w[
    PRIMARY
    SECONDARY
  ].freeze

  belongs_to :institution
end
