# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe CalculatorConstantVersion, type: :model do
  it_behaves_like 'an exportable model', skip_lines: 0
end
