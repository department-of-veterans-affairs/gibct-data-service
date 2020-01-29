# frozen_string_literal: true

module Facets
  # rubocop:disable Lint/BooleanSymbol
  def boolean_facet
    { true: nil, false: nil }
  end
  # rubocop:enable Lint/BooleanSymbol

  def count_field(relation, field)
    field_map = Hash.new(0)
    relation.map do |program|
      value = program.send(field)
      field_map[value] += 1 if value.present?
    end
    field_map
  end

  def add_search_facet(raw_facets, field)
    # binding.pry
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
