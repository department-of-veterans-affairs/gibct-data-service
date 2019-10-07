# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionedSchoolCertifyingOfficialsArchive, type: :model do
  it_behaves_like 'an archivable model',
                  original_type: VersionedSchoolCertifyingOfficial,
                  factory: :versioned_school_certifying_official
end
