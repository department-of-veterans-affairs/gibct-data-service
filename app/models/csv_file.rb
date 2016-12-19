# frozen_string_literal: true
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
    begin
      prep_load
      load_data

      self.result = 'Successful'
    rescue StandardError => e
      msg = "Tried to upload: #{e.message}"
      Rails.logger.error msg

      errors.add(:base, msg)
      self.result = 'Failed'
    end

    true
  end

  def prep_load
    model_from_csv_type.delete_all
    data_from_csv_file
    headers_from_csv_file
    check_headers
    generate_header_converter
  end

  def model_from_csv_type
    @model ||= TYPES.find { |r| r.name.casecmp(csv_type.downcase).zero? }
  end

  def data_from_csv_file
    @data ||= upload_file.read.encode(Encoding.find('UTF-8'), ENCODING_OPTIONS)
  end

  def headers_from_csv_file
    n = 0
    @headers ||= CSV.parse(data_from_csv_file) do |row|
      next if (n += 1) <= skip_lines_before_header
      break row.map { |r| r.try(:strip).try(:downcase) }
    end
  end

  def check_headers
    missing_headers = model_from_csv_type::HEADER_MAP.keys - headers_from_csv_file
    raise StandardError, "#{name} missing headers: #{missing_headers.inspect}" if missing_headers.present?
  end

  def generate_header_converter
    CSV::HeaderConverters[:header_map] = lambda do |header|
      begin
        h = model_from_csv_type::HEADER_MAP[header.try(:strip)]
        raise StandardError, "Header '#{header}' not found in #{model_from_csv_type} model" if h.blank?

        h
      end
    end
  end

  # Read strings terminated by \n, process and save in a single transaction
  def load_data
    n = 0

    model_from_csv_type.transaction do
      CSV.parse(data_from_csv_file, headers: headers_from_csv_file, header_converters: [:downcase, :header_map]) do |r|
        n += 1
        next if n <= skip_lines_before_header + skip_lines_after_header + 1

        # The model is afforded the opportunity to validate the row before a model is created
        process_rows(r, n) if model_from_csv_type.permit_csv_row_before_save
      end
    end
  end

  def process_rows(row, n)
    instance = model_from_csv_type.new(row.to_hash)
    instance.save_for_bulk_insert!
  rescue StandardError => e
    raise "Row #{n}: #{e.message}\n#{Rails.logger.error e.backtrace}"
  end

  protected

  # allow the creation only
  def readonly?
    new_record? ? false : true
  end
end
