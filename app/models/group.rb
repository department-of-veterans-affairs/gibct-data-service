# frozen_string_literal: true

class Group < Upload
  include RooHelper

  attr_accessor :sheet_type_list, :group_config, :parse_as_xml

  def initialize(attributes = nil)
    super(attributes)
    self.group_config = Group.group_config_options(csv_type) || {}
  end

  def self.create_from_group_type(group_type)
    group = Group.new(group_type)
    group.parse_as_xml = group.group_config[:parse_as_xml?]
    group
  end

  def self.group_config_options(group_type)
    GROUP_FILE_TYPES.select { |g| g[:klass] == group_type }.first
  end

  def sheet_names
    @sheet_names ||= group_config[:types]&.map(&:name)
  end

  def sheets
    @sheets ||= group_config[:types]
  end

  def xml_error_help
    @xml_error_help ||= group_config[:xml_error_help]
  end
end
