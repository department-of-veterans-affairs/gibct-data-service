# frozen_string_literal: true

module InstitutionBuilder
  class IpedsBuilder
    extend Common

    def self.build_ic(version_id)
      str = <<-SQL
        institutions.cross = ipeds_ics.cross
      SQL

      add_columns_for_update(version_id, IpedsIc, str)
    end

    def self.build_hd(version_id)
      str = <<-SQL
        UPDATE institutions SET #{columns_for_update(IpedsHd)}
        FROM ipeds_hds
        WHERE institutions.cross = ipeds_hds.cross
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end

    def self.build_ic_ay(version_id)
      str = <<-SQL
        institutions.cross = ipeds_ic_ays.cross
      SQL

      add_columns_for_update(version_id, IpedsIcAy, str)
    end

    def self.build_ic_py(version_id)
      columns = IpedsIcPy::COLS_USED_IN_INSTITUTION.map(&:to_s).map do |col|
        %("#{col}" = CASE WHEN institutions.#{col} IS NULL THEN ipeds_ic_pies.#{col} ELSE institutions.#{col} END)
      end.join(', ')

      str = <<-SQL
        UPDATE institutions SET #{columns}
        FROM ipeds_ic_pies
        WHERE institutions.cross = ipeds_ic_pies.cross
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end
  end
end
