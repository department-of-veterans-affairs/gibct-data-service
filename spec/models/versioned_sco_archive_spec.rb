# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_archivable'

RSpec.describe VersionedScoArchive, type: :model do
  it_behaves_like 'an archivable model', original_type: VersionedSchoolCertifyingOfficial, factory: :versioned_school_certifying_official
end