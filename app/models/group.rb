# frozen_string_literal: true

class Group < Upload
  include RooHelper

  attr_accessor :sheet_type_list, :group_config

  def initialize(attributes = nil)
    super(attributes)
    self.group_config = Group.group_config_options(csv_type)
  end
  
  def self.group_config_options(group_type)
    GROUP_FILE_TYPES.select { |g| g[:klass] == group_type }.first
  end

  def parse_as_xml
    @parse_as_xml ||= group_config[:parse_as_xml?]
  end

  def sheet_names
    @sheet_names ||= group_config[:types].map(&:name)
  end

  def sheets
    @sheets ||= group_config[:types]
  end
end
