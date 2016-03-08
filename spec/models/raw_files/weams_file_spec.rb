require 'rails_helper'
require "support/shared_examples_for_raw_file_sti"

RSpec.describe WeamsFile, type: :model do
	it_behaves_like "a raw file sti model", :weams_file
end