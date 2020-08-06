# frozen_string_literal: true

class CautionFlag < ApplicationRecord

  belongs_to :institution, counter_cache: :count_of_caution_flags
  scope :distinct_flags, lambda {
    select('title, description, link_text, link_url, flag_date').distinct
  }

  def self.build(version_id, cf_template, clause_sql)
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection
    insert_columns = %i[
      institution_id version_id source reason title description
      link_text link_url created_at updated_at
    ]

    <<-SQL
          INSERT INTO caution_flags (#{insert_columns.join(' , ')})
          SELECT institutions.id,
              #{version_id} as version_id,
              '#{cf_template::NAME}' as source,
              #{cf_template::REASON_SQL} as reason,
              '#{cf_template::TITLE}' as title,
              '#{cf_template::DESCRIPTION}' as description,
              '#{cf_template::LINK_TEXT}' as link_text,
              '#{cf_template::LINK_URL}' as link_url,
              #{conn.quote(timestamp)} as created_at,
              #{conn.quote(timestamp)} as updated_at
          #{clause_sql}
    SQL

    sql = CautionFlag.send(:sanitize_sql, [str])
    CautionFlag.connection.execute(sql)
  end
end
