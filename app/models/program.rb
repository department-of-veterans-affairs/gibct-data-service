# frozen_string_literal: true

class Program < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution_name, converter: InstitutionConverter },
    'program type' => { column: :program_type, converter: BaseConverter },
    'description' => { column: :description, converter: BaseConverter },
    'full time undergraduate' => { column: :full_time_undergraduate, converter: BaseConverter },
    'graduate' => { column: :graduate, converter: BaseConverter },
    'full time modifier' => { column: :full_time_modifier, converter: BaseConverter },
    'length' => { column: :length, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :program_type, inclusion: { in: InstitutionProgram::PROGRAM_TYPES }

  def self.after_import_batch_validations(records, failed_instances, row_offset)
    @duplicate_results = duplicate_facility_description_results
    @facility_not_in_weam = missing_facility_in_weam
    @row_offset = row_offset

    group_size = Settings.csv_upload.batch_size.validation
    # starting this at -1 since incrementing before potentially lengthy validate_group method is kicked off
    # this variable uses Mutex class to implement a simple semaphore lock for mutually exclusive access
    # to preserve which row in the CSV is being referenced for user to look at row for specified error
    group_index = -1
    mutex = Mutex.new

    records.in_groups_of(group_size, fill_with = false) do |group|
      t = Thread.new{
        mutex.synchronize do
          group_index += 1
        end
        validate_group(group, group_index * group_size,failed_instances)
      }
      t.join
    end
  end

  def self.validate_group(group, group_offset, failed_instances)
    group.each_with_index do |record, index|
      csv_row = index + group_offset
      duplicate = @duplicate_results.to_a
                      .include?('facility_code' => record.facility_code&.upcase,
                                'description' => record.description&.upcase)
      missing_facility = @facility_not_in_weam.to_a.include?('facility_code' => record.facility_code&.upcase)

      return unless duplicate || missing_facility

      record.errors[:base] << non_unique_error_msg(record) if duplicate
      record.errors[:base] << BaseValidator.missing_facility_error_msg(record) if missing_facility
      record.errors.add(:row, "Line #{csv_row + @row_offset}")
      failed_instances << { :index => csv_row, :record => record } if record.persisted?
    end

    puts "finished group #{group_offset}"
  end

  def self.duplicate_facility_description_results
    str = <<-SQL
      SELECT
          UPPER(facility_code) facility_code,
          UPPER(description) description
        FROM programs
        GROUP BY
          UPPER(facility_code),
          UPPER(description)
        HAVING COUNT(*) > 1
    SQL

    sql = Program.send(:sanitize_sql, [str])
    Program.connection.execute(sql)
  end

  def self.missing_facility_in_weam
    str = <<-SQL
      SELECT programs.facility_code
      FROM programs LEFT OUTER JOIN weams ON programs.facility_code = weams.facility_code
      WHERE weams.facility_code IS NULL
    SQL
    sql = Program.send(:sanitize_sql, [str])
    Program.connection.execute(sql)
  end

  def self.non_unique_error_msg(record)
    "The Facility Code & Description (Program Name) combination is not unique:
#{record.facility_code}, #{record.description}"
  end
end
