# frozen_string_literal: true

class VersionedComplaint < ApplicationRecord
  belongs_to :version
end
