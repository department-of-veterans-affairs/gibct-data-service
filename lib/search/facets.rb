# frozen_string_literal: true

module Facets
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

  def normalized_query_params
    query = params.deep_dup
    query.tap do
      query[:name].try(:strip!)
      query[:name].try(:downcase!)
      %i[state country type].each do |k|
        query[k].try(:upcase!)
      end

      %i[category student_veteran_group yellow_ribbon_scholarship principles_of_excellence
         eight_keys_to_veteran_success stem_offered independent_study priority_enrollment
         online_only distance_learning vet_tec_provider].each do |k|
        query[k].try(:downcase!)
      end
    end
  end
end
