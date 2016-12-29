# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_savable'
require 'models/shared_examples/shared_examples_for_standardizable'

RSpec.describe Crosswalk, type: :model do
  it_behaves_like 'a savable model', Crosswalk
  it_behaves_like 'a standardizable model', Crosswalk
end
