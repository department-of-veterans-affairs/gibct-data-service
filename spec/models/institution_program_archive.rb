# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_archivable'

RSpec.describe InstitutionProgramArchive, type: :model do
  it_behaves_like 'an archivable model', original_type: InstitutionProgram, factory: :institution_program
end
