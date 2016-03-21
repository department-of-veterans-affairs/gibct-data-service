require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe ArfGibillCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :arf_gibill_csv_file
end