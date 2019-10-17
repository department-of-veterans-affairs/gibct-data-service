# frozen_string_literal: true

module Facets
  def boolean_facet
    { true: nil, false: nil }
  end

  def named_search_facet(raw_facets, facet_name)
    return if @query[facet_name].blank?
    key = @query[facet_name].downcase
    raw_facets[facet_name][key] = 0 unless raw_facets[facet_name].key? key
  end
end
