# frozen_string_literal: true

module Facets
  # rubocop:disable Lint/BooleanSymbol
  def boolean_facet
    { true: nil, false: nil }
  end
  # rubocop:enable Lint/BooleanSymbol

  def add_search_facet(raw_facets, field)
    return if @query[field].blank?

    key = @query[field].downcase
    raw_facets[field][key] = 0 unless raw_facets[field].key? key
  end

  def add_country_search_facet(raw_facets)
    return if @query[:country].blank?

    key = @query[:country].upcase
    raw_facets[:country] << { name: key, count: 0 } unless
        raw_facets[:country].any? { |c| c[:name] == key }
  end

  def embed(group_counts)
    group_counts.each_with_object([]) do |(k, v), array|
      array << { name: k, count: v }
    end
  end
end
