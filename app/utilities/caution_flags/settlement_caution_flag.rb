# frozen_string_literal: true

class SettlementCautionFlag
  def self.build(version_id)
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection
    insert_columns = %i[
      institution_id version_id source reason title description
      link_url flag_date created_at updated_at
    ]

    flag_date_sql = <<-SQL
      CASE WHEN va_caution_flags.settlement_date IS NOT NULL 
        THEN TO_DATE(va_caution_flags.settlement_date, 'MM/DD/YY') 
        ELSE null END
    SQL

    <<-SQL
          INSERT INTO caution_flags (#{insert_columns.join(' , ')})
          SELECT institutions.id,
              #{version_id} as version_id,
              'Settlement' as source,
              va_caution_flags.settlement_description as reason,
              va_caution_flags.settlement_title as title,
              va_caution_flags.settlement_description as description,
              va_caution_flags.settlement_link as link_url,
              #{flag_date_sql} as flag_date,
              #{conn.quote(timestamp)} as created_at,
              #{conn.quote(timestamp)} as updated_at
	        FROM institutions JOIN va_caution_flags ON institutions.facility_code = va_caution_flags.facility_code
          WHERE institutions.version_id = #{version_id}
    SQL

    sql = CautionFlag.send(:sanitize_sql, [str])
    CautionFlag.connection.execute(sql)
  end
end
