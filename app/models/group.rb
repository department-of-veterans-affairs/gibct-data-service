# frozen_string_literal: true

class Group < Upload
  include RooHelper

  attr_accessor :sheet_type_list, :group_config

  def self.from_group_type(group_type)
    group_config = group_config_options(group_type)

    group = Group.new(csv_type: group_config[:klass])
    group.group_config = group_config

    group
  end

  def self.group_config_options(group_type)
    GROUP_FILE_TYPES.select { |g| g[:klass] == group_type }.first
  end

  def parse_as_xml
    @parse_as_xml ||= Group.group_config_options(csv_type)[:parse_as_xml?]
  end
end
