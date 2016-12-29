# frozen_string_literal: true
require 'csv'

class CsvFile < ActiveRecord::Base
  TYPES = [Weam, Crosswalk].freeze
  DELIMITERS = %w(, |).freeze
  ENCODING_OPTIONS = { invalid: :replace, undef: :replace, replace: '', universal_newline: true }.freeze

  before_save :upload_csv_file

  attr_accessor :upload_file

  belongs_to :user, inverse_of: :csv_files

  validates_associated :user
  validates :user_id, presence: true

  validates :csv_type, inclusion: { in: TYPES.map(&:name), message: '%{value} is not a valid CSV type' }
  validates :name, presence: true

  validates :skip_lines_before_header, presence: true, numericality: { only: :integer, greater_than_or_equal_to: 0 }
  validates :skip_lines_after_header, presence: true, numericality: { only: :integer, greater_than_or_equal_to: 0 }

  validates :delimiter, inclusion: { in: DELIMITERS, message: '%{value} is not a valid delimiter' }

  # Loads some default parameters for CSV file formats
  def self.defaults_for(type)
    YAML.load_file('config/csv_file_defaults.yml')[type.to_s]
  end

  # Finds the most recent upload grouped by csv_type
  def self.last_uploads(success = true)
    result = success ? 'Successful' : 'Failed'

    inner_query = 'SELECT cf.csv_type as ctype, MAX(cf.created_at) as max_ca '\
                  'FROM csv_files cf '\
                  "WHERE cf.result='#{result}' "\
                  'GROUP BY cf.csv_type'

    query = 'SELECT csv_files.* '\
      "FROM csv_files INNER JOIN (#{inner_query}) md "\
      'ON md.ctype=csv_files.csv_type '\
      "WHERE md.max_ca=csv_files.created_at AND csv_files.result='#{result}';"

    find_by_sql(query)
  end

  # Kicks off csv loading of model
  def upload_csv_file
    self.result = 'Failed'

    begin
      precheck!
      load_data!

      self.result = 'Successful'
    rescue StandardError => e
      msg = "Tried to upload: #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error msg + "\n#{e.backtrace}"
    end

    true
  end

  # Prechecks columns vs csv headers for the model and installs CSV header_converters
  def precheck!
    columns = model::HEADER_MAP.keys
    missing = columns - headers
    raise StandardError, "#{name} is missing headers: #{missing.inspect}" if missing.present?

    extra = headers - columns
    raise StandardError, "#{name} has extra headers: #{extra.inspect}" if extra.present?

    CSV::HeaderConverters[:header_map] = lambda do |header|
      model::HEADER_MAP[header.try(:strip).try(:downcase)]
    end
  end

  # Attempts to read the csv file line-by-line and save
  def load_data!
    n = 0
    model.delete_all
    first_row = skip_lines_before_header + skip_lines_after_header + 1

    model.transaction do
      CSV.parse(data, headers: headers, header_converters: [:downcase, :header_map]) do |row|
        next if (n += 1) <= first_row || !model.permit_csv_row_before_save(row)

        begin
          model.create!(row.to_hash)
        rescue ActiveRecord::RecordInvalid => e
          raise ActiveRecord::RecordInvalid, "On row #{n}: #{e.message}"
        end
      end
    end
  end

  protected

  # Gets the model used for this type of csv
  def model
    @model ||= TYPES.find { |r| r.name.casecmp(csv_type.downcase).zero? }
  end

  # Reads and encodes temporary uploaded csv file
  def data
    @data ||= upload_file.read.encode(Encoding.find('UTF-8'), ENCODING_OPTIONS)
  end

  # Reads the csv file headers
  def headers
    n = 0

    @headers ||= CSV.parse(data) do |row|
      next if (n += 1) <= skip_lines_before_header
      break row.map { |r| r.try(:strip).try(:downcase) }
    end
  end

  # allow the creation only
  def readonly?
    new_record? ? false : true
  end
end
