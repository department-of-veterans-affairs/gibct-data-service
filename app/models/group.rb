# frozen_string_literal: true

class Group < Upload
  include RooHelper

  attr_accessor :sheet_type_list, :group_config

  def initialize(attributes = nil)
    super(attributes)
    self.group_config = Group.group_config_options(csv_type) || {}
  end

  def sheet_names
    @sheet_names ||= group_config[:types]&.map(&:name)
  end

  def sheets
    @sheets ||= group_config[:types]
  end

  def self.group_config_options(group_type)
    GROUP_FILE_TYPES.select { |g| g[:klass] == group_type }.first
  end

  # For each type in the config create a CSV file within the Zip::OutputStream
  # Returns the binary data for the zip file
  def self.export_to_data(group_type)
    Zip::OutputStream.write_buffer do |zio|
      group_config_options(group_type)[:types].each do |type|
        zio.put_next_entry("#{type}.csv")
        zio.write type.export
      end
    end.string
  end
end
