# frozen_string_literal: true

module InstitutionTree
  def self.build(institution)
    main = main_campus(institution)
    all = descendants(main)

    {
      'main' => {
        'institution' => main,
        'branches' => build_branches(all),
        'extensions' => build_extensions(all, main.facility_code)
      }
    }
  end

  class << self
    private

    def build_branches(institutions)
      branches = []
      institutions.each do |institution|
        next unless institution['campus_type'] == 'N'
        branches << {
          'institution' => institution,
          'extensions' => build_extensions(institutions, institution['facility_code'])
        }
      end
      branches.sort_by { |branch| branch['institution']['institution'] }
    end

    def build_extensions(institutions, facility_code)
      extensions = []
      institutions.each do |institution|
        next unless institution['parent_facility_code_id'] == facility_code && institution['campus_type'] == 'E'
        extensions << institution
      end
      extensions.sort_by { |extension| extension['institution'] }
    end

    def main_campus(institution)
      return institution if institution.campus_type == 'Y' || institution.campus_type.nil?

      str = <<-SQL
        WITH RECURSIVE related_up AS(
          SELECT campus_type, facility_code, parent_facility_code_id
          FROM institutions WHERE facility_code = ? AND version = ?
          UNION
            SELECT
              i.campus_type, i.facility_code, i.parent_facility_code_id
            FROM institutions i
            INNER JOIN related_up r ON r.parent_facility_code_id = i.facility_code
            WHERE i.version = ?
        ) SELECT * FROM related_up where campus_type = 'Y'
      SQL
      sql = Institution.send(:sanitize_sql,
                             [str, institution.facility_code, institution.version, institution.version])
      main_facility_code = Institution.connection.execute(sql).first['facility_code']

      Institution.find_by(facility_code: main_facility_code)
    end

    def descendants(ancestor)
      str = <<-SQL
        WITH RECURSIVE related_down AS(
          SELECT facility_code
          FROM institutions
          WHERE facility_code = ? AND version = ?
          UNION
            SELECT i.facility_code
            FROM institutions i
            INNER JOIN related_down r ON i.parent_facility_code_id = r.facility_code
            WHERE i.version = ?
        ) SELECT facility_code FROM related_down WHERE facility_code != ?
      SQL

      sql = Institution.send(:sanitize_sql,
                             [str, ancestor.facility_code, ancestor.version, ancestor.version, ancestor.facility_code])
      facility_codes = Institution.connection.execute(sql).field_values('facility_code')

      Institution.where(facility_code: facility_codes)
    end
  end
end
