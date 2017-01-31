# frozen_string_literal: true
require 'csv'

namespace :gids do
  desc 'Load database from CSV -- invoke with rake load_csv[file_name.csv]'
  task :load_csv, [:csv_file] => [:environment] do |_t, args|
    abort('Not intended for screwing up production.') if Rails.env.production?

    puts 'Clearing logs ...'
    Rake::Task['log:clear'].invoke

    puts 'Delete records in Institution in preparation for loading ...'
    Institution.delete_all

    puts "Loading #{args[:csv_file]} ... "
    count = 0

    ActiveRecord::Base.transaction do
      CSV.foreach(args[:csv_file], headers: true, encoding: 'iso-8859-1:utf-8', header_converters: :symbol) do |row|
        count += 1

        row = LoadCsvHelper.convert(row.to_hash)
        unless (i = Institution.create(row)).persisted?
          reason = i.errors.to_a.join(', ')

          puts "\nRecord: #{count}: #{i.institution} not created! - #{reason}\n"
          Rails.logger.error "Record: #{count}, #{i.institution} not created! - #{reason}"
        end

        print "\r Records: #{count}"
      end
    end

  	 puts "\nDone ... Woo Hoo!"
  end
end

class LoadCsvHelper
  TRUTHY = %w(yes true t 1).freeze
  COLUMNS_NOT_IN_CSV = %w(id institution_type_name created_at updated_at).freeze

  CONVERSIONS = {
    string: :to_str, float: :to_float, integer: :to_int, boolean: :to_bool
  }.freeze

  # Gets Institution column names, returning only those columns that are in
  # the CSV data file.
  #
  def self.all_columns
    columns = Institution.column_names || []
    COLUMNS_NOT_IN_CSV.each { |col_name| columns.delete(col_name) }

    columns
  end

  # Converts the columns in the csv row to an appropriate data type for the
  # Institution and InstitutionType models.
  #
  # rubocop:disable AbcSize
  def self.convert(row)
    # For each column name in the CSV, get the column's data type and convert
    # the row to the appropriate type.
    cnv_row = {}

    all_columns.each do |name|
      col_type = Institution.columns_hash[name].type
      next unless CONVERSIONS[col_type]

      cnv = LoadCsvHelper.send(conversion, row[name.to_sym])
      case col_type
      when :integer || :float
        cnv_row[name.to_sym] = cnv if cnv.present?
      else
        cnv_row[name.to_sym] = cnv
      end
    end

    cnv_row[:institution_type_name] = to_institution_type(row)
    cnv_row[:zip] = pad_zip(row)

    cnv_row
  end
  # rubocop:enable AbcSize

  # Converts CSV type data to an associated type in the database. Also
  # removes fields in the CSV that have become redundant.
  #
  def self.to_institution_type(row)
    name = row[:type].downcase
    [:type, :correspondence, :flight].each { |key| row.delete(key) }
    name
  end

  # Pads the CSV zip code to 5 characters if necessary.
  #
  def self.pad_zip(row)
    row[:zip].present? ? row[:zip].try(:rjust, 5, '0') : nil
  end

  ## Converts the string value to a boolean.
  #
	 def self.to_bool(value)
    TRUTHY.include?(value.try(:downcase))
 	end

  # Converts the string value to a integer. Removes numeric formatting
  # characters.
  #
  def self.to_int(value)
    value = value.try(:gsub, /[\$,]|null/i, '')
    value.present? ? value : nil
  end

  # Converts the string value to a float. Removes numeric formatting
  # characters.
  #
  def self.to_float(value)
    value = value.try(:gsub, /[\$,]|null/i, '')
    value.present? ? value : nil
  end

  # Removes single and double quotes from strings.
  #
  def self.to_str(value)
    value = value.to_s.gsub(/["']|\Anull\z/, '').truncate(255)
    value.present? ? value : nil
  end
end
