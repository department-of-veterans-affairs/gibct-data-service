# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolCertifyingOfficialsArchive, type: :model do
  it_behaves_like 'an archivable model by parent id',
                  original_type: SchoolCertifyingOfficial,
                  factory: :school_certifying_official
end
