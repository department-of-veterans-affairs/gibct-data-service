# frozen_string_literal: true

module Lcpe
  extend SqlContext

  def self.table_name_prefix
    'lcpe_'
  end
end
