# frozen_string_literal: true

module Common
  def self.included(base)
    base.extend Shared
  end

  module Shared
    def klass
      name.constantize
    end
  end
end
