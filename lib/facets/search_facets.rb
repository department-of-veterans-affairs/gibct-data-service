# frozen_string_literal: true

module Facets
  def default_b_boolean_facet
    { true: nil, false: nil }
  end
  module SearchFacets
    def default_a_boolean_facet
      { true: nil, false: nil }
    end

    def add_a_named_search_facet(raw_facets, facet_name)
      return if @query[facet_name].blank?
      key = @query[facet_name].downcase
      raw_facets[facet_name][key] = 0 unless raw_facets[facet_name].key? key
    end
  end
end
