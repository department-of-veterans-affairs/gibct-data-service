# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_archivable_by_version_id'

RSpec.describe InstitutionsArchive, type: :model do
  it_behaves_like 'an archivable model by version id', original_type: Institution, factory: :institution
end
