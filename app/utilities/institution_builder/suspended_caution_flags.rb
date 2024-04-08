# frozen_string_literal: true

module InstitutionBuilder
  class SuspendedCautionFlags
    extend Common

    def self.build(version_id)
      str = <<-SQL
        UPDATE institutions SET
          caution_flag = TRUE,
          caution_flag_reason = 'caution_flag_reason'
        WHERE institutions.poo_status = 'SUSP'
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      caution_flag_clause = <<-SQL
        FROM institutions
        WHERE institutions.poo_status = 'SUSP'
        AND institutions.version_id = #{version_id}
      SQL

      CautionFlag.build(version_id, CautionFlagTemplates::PooStatusFlag, caution_flag_clause)
    end
  end
end
