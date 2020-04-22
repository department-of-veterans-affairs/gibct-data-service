# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution, counter_cache: :count_of_caution_flags

  def self.map(version_id)
    engine = Rule.create_engine

    # Get distinct predicates
    predicates = Rule.select(:predicate).where(rule_name: CautionFlag.name).distinct.pluck(:predicate)

    # Load all caution flag rows into engine for each predicate
    where(version_id: version_id).find_each do |cf|
      predicates.map(&:to_sym).each do |predicate|
        object = cf[predicate]
        engine << [cf.id, predicate, object.is_a?(String) ? object.downcase : object]
      end
    end

    # Apply rules. rule priority is :source rules first, then :reason rules
    CautionFlagRule.includes(:rule).order('rules.priority ASC').references(:rule).find_each do |cf_rule|
      caution_flag_ids = Rule.apply_rule(engine, cf_rule.rule)
      apply_update(cf_rule, caution_flag_ids) unless caution_flag_ids.empty?
    end
  end

  def self.cols_to_update(cols_map_update)
    cols_map_update.map(&:to_s)
                   .map { |col| %(#{col} = #{CautionFlagRule.table_name}.#{col}) }.join(', ')
  end

  def self.apply_update(rule, caution_flag_ids)
    if rule.link_url == CautionFlagRule::SCHOOL_URL
      str = update_for_school_url(rule, caution_flag_ids)
    else
      cols_map_update = %i[
        title description link_text link_url
      ]
      str = <<-SQL
            UPDATE #{table_name} SET #{cols_to_update(cols_map_update)}
            FROM #{CautionFlagRule.table_name}
            WHERE #{CautionFlagRule.table_name}.id = #{rule.id} AND #{table_name}.id in (#{caution_flag_ids.join(',')})
      SQL
    end

    CautionFlag.connection.update(str)
  end

  def self.update_for_school_url(rule, caution_flag_ids)
    cols_map_update = %i[
      title description
    ]
    <<-SQL
            UPDATE #{table_name} SET #{cols_to_update(cols_map_update)},
            link_text = CASE
              WHEN #{Institution.table_name}.insturl IS NULL THEN
                #{CautionFlagRule.table_name}.link_text || '.'
              ELSE
                #{CautionFlagRule.table_name}.link_text
              END,
            link_url = CASE
              WHEN LEFT(LOWER(#{Institution.table_name}.insturl), 4) != 'http' THEN
                'http://' || #{Institution.table_name}.insturl
              ELSE
                #{Institution.table_name}.insturl
              END
          FROM #{CautionFlagRule.table_name}, #{Institution.table_name}
          WHERE #{CautionFlagRule.table_name}.id = #{rule.id}
          AND #{table_name}.id in (#{caution_flag_ids.join(',')})
          AND #{Institution.table_name}.id = #{table_name}.institution_id
    SQL
  end
end
