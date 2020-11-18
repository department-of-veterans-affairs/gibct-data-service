# frozen_string_literal: true

module RooHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Loader
    base.extend Common::Exporter
  end

  def self.valid_col_seps
    valid_col_seps = Settings.csv_upload.column_separators.each(&:to_s)
    { value: valid_col_seps, message: 'Valid column separators are:' }
  end
end
