module Lcpe::Feed
  def self.table_name_prefix
    # not going to be pedantic
    # parent_pfx = self.module_parent.table_name_prefix
    # pfx = "feed_"
    # format("%<parent_pfx>s%<pfx>s", {parent_pfx:, pfx:})

    "lcpe_feed_"
  end
end
