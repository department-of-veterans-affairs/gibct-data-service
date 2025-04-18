# frozen_string_literal: true

module VersionedComplaintRollup
  def self.compute_yearly_rollup_by_facility_code(institution, years)
    sql = build_query(years, {facility_code: institution.facility_code})
    result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(sql))
    format_result(result)
  end

  def self.compute_yearly_rollup_by_ope6(institution, years)
    return {} if institution.has_generic_ope6?

    sql = build_query(years, {ope6: institution.ope6})
    result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(sql))
    format_result(result)
  end

  # The raw result is a bunch of rows of the form
  # {year: 2025, count: 3, cfbfc: nil, cqbfc: 0, crbfc: 1, ...}
  # {year: 2025, count: 2, cfbfc: 1, cqbfc: nil, crbfc: nil, ...}
  # Due to the way GROUPING SETS works we'll end up with a few
  # unnecessary result rows. We want to group by year, and within
  # each of those groups find the rows where a field equals '1'
  # and read the 'count' from that row. For example, given the row
  # {year: 2025, count: 2, cfbfc: 1, cqbfc: nil, crbfc: nil, ...} we
  # know that in the year 2025 there were 2 complaints with type
  # cfbfc (financial). So we'll try to format it nicely in an object
  # like {2025 => {financial: 2, ...}, ...}
  def self.format_result(result)
    result = result.group_by{|e| e['year']}
    result.transform_values! do |year_group|
      year_group.reduce({}) do |o, res|
        type_name, _ = res.find{|key,val| val == 1 && (key != 'count')}
        o[type_name] = res['count']
        o
      end.reject{|k,v| k.nil?}
    end
  end

  def self.build_query(years, where_filter)
      where_clause = where_filter.map do |k,v|
        "complaints.#{k} = '#{v}'"
      end.join(' AND ')

      sql = <<-SQL
      SELECT EXTRACT(YEAR FROM TO_DATE(closed, 'YYYY-MM-DD'))::int AS year,
        cfc "facility_code",
        cfbfc "financial",
        cqbfc "quality",
        crbfc "refund",
        cmbfc "recruit",
        cabfc "accreditation",
        cdrbfc "degree",
        cslbfc "loans",
        cgbfc "grade",
        cctbfc "transfer",
        cjbfc "job",
        ctbfc "transcript",
        cobfc "other",
      COUNT(*) AS COUNT FROM complaints
      WHERE #{where_clause}
      AND EXTRACT(YEAR FROM TO_DATE(closed, 'YYYY-MM-DD'))::int IN (#{years.join(',')})
      AND complaints.closed IS NOT NULL
      AND complaints.closed != ''
      GROUP BY
        GROUPING SETS (
            (year, cfc),
            (year, cfbfc),
            (year, cqbfc),
            (year, crbfc),
            (year, cmbfc),
            (year, cabfc),
            (year, cdrbfc),
            (year, cslbfc),
            (year, cgbfc),
            (year, cctbfc),
            (year, cjbfc),
            (year, ctbfc),
            (year, cobfc)
        );
      SQL
  end
end