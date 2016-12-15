require 'CSV'

class CsvFile < ActiveRecord::Base
  TYPES = [Weam].freeze
  DELIMITERS = %w(, |).freeze
  ENCODING_OPTIONS = { invalid: :replace, undef: :replace, replace: '', universal_newline: true }.freeze

  before_save :upload_csv_file

  attr_accessor :upload_file

  validates :csv_type, inclusion: { in: TYPES.map(&:name), message: '%{value} is not a valid CSV type' }
  validates :name, :user, presence: true

  validates :skip_lines_before_header, presence: true, numericality: { only: :integer, greater_than_or_equal_to: 0 }
  validates :skip_lines_after_header, presence: true, numericality: { only: :integer, greater_than_or_equal_to: 0 }

  validates :delimiter, inclusion: { in: DELIMITERS, message: '%{value} is not a valid delimiter' }

  def self.defaults_for(type)
    YAML.load_file('config/csv_file_defaults.yml')[type.to_s]
  end

  # Kicks off csv loading of model
  def upload_csv_file
    prep_model

    begin
      data = upload_file.read.encode(Encoding.find('UTF-8'), ENCODING_OPTIONS)
      load_data_into(model, data)
      self.result = 'Successful'
    rescue StandardError => e
      errors[:base] << e.message
      self.result = 'Failed'
    end

    true
  end

  def prep_model
    model = TYPES.find { |r| r.name.casecmp(csv_type.downcase).zero? }
    model.delete_all

    model
  end

  # Read strings terminated by \n, process and save in a single transaction
  def load_data_into(model, data)
    n = 0

    model.transaction do
      CSV.parse(data, headers: process_headers(model, data)) do |row|
        n += 1
        next if n <= skip_lines_before_header + skip_lines_after_header + 1

        # The model is afforded the opportunity to validate the row before a model is created
        process_rows(model, row, n) if model.permit_csv_row_before_save
      end
    end
  end

  def process_headers(model, data)
    n = 0
    headers = CSV.parse(data) do |row|
      next if (n += 1) <= skip_lines_before_header
      break row.map { |r| r.strip.downcase }
    end

    missing_headers = model::HEADER_MAP.keys - headers
    raise StandardError, "#{name} missing headers: #{missing_headers.inspect}" if missing_headers.present?

    headers
  end

  def process_rows(model, row, n)
    instance = model.new(row)
    instance.save_for_bulk_insert!
  rescue StandardError => e
    raise e.class, "Row #{n}: #{e.message}"
  end

  protected

  # allow the creation only
  def readonly?
    new_record? ? false : true
  end
end
