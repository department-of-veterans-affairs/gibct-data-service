# frozen_string_literal: true

module Lcpe::Feed
  def self.table_name_prefix
    # not going to be pedantic
    # parent_pfx = self.module_parent.table_name_prefix
    # pfx = "feed_"
    # format("%<parent_pfx>s%<pfx>s", {parent_pfx:, pfx:})

    'lcpe_feed_'
  end

  # Each Lcpe::Feed:: model must define the NORMALIZED_KLASS it's associated with
  # For example, Lcpe::Feed::Nexam normalizes to Lcpe::Exam
  def self.normalized_klasses
    Lcpe::Feed.constants.map do |const|
      feed_klass = Lcpe::Feed.const_get(const)
      feed_klass.const_get(:NORMALIZED_KLASS)
    end
  end
end
