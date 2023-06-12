# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution, counter_cache: :count_of_caution_flags
  scope :distinct_flags, lambda {
    select('title, description, link_text, link_url').distinct
  }

  def self.build(version_id, cf_template, clause_sql)
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection
    insert_columns = %i[
      institution_id version_id source title description
      link_text link_url created_at updated_at
    ]

    str = <<-SQL
          INSERT INTO caution_flags (#{insert_columns.join(' , ')})
          SELECT institutions.id,
              #{version_id} as version_id,
              '#{cf_template::NAME}' as source,
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

  # Inclusion of template name limits cloning of old rows to that type of caution flag
  # Types of caution flags identified so far are: AccreditationAction, Mou, Sec702, Hcm
  def self.initialize_with_current(version_id, cf_template_name, clause_sql)
    message = "Creating Caution Flag rows from current Caution Flags for #{cf_template_name}"
    Rails.logger.info "*** #{Time.now.utc} #{message}"
    UpdatePreviewGenerationStatusJob.perform_later(message)

    insert_columns, columns = set_columns_for_sql

    str  = "INSERT INTO caution_flags (#{insert_columns.join(', ')}) "
    str += "select new_i.id, #{version_id}, #{columns.join(', ')} "
    str += 'from caution_flags  '
    str += '  inner join institutions old_i on caution_flags.institution_id = old_i.id '
    str += "    and old_i.version_id = #{Version.current_production.id}"
    str += 'inner join institutions new_i on old_i.facility_code = new_i.facility_code '
    str += 'where institution_id = old_i.id '
    str += "  and caution_flags.version_id = #{Version.current_production.id} "
    str += "  and source = #{cf_template_name}"
    str += clause_sql unless clause_sql.nil?

    CautionFlag.connection.insert(str) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def set_columns_for_sql
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection
    columns = Array.new(CautionFlagTemplate.column_names)
    columns.delete('id')
    insert_columns = columns.dup
    columns.delete('version_id')
    columns.map! { |cn| cn.eql?('created_at') ? conn.quote(timestamp) : cn }
    columns.map! { |cn| cn.eql?('updated_at') ? conn.quote(timestamp) : cn }
    columns.map! { |cn| cn.eql?('version_id') ? version.id.to_i : cn }

    [insert_columns, columns]
  end
end
