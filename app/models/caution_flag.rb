# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution

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
      subjects = Rule.apply_rule(engine, cf_rule.rule)
      apply_update(cf_rule, subjects) unless subjects.empty?
    end
  end

  def self.cols_to_update(cols_map_update)
    cols_map_update.map(&:to_s)
        .map { |col| %(#{col} = #{CautionFlagRule.table_name}.#{col}) }.join(', ')
  end

  def self.apply_update(rule, ids)
    cols_map_update = %i[
      title description link_text link_url
    ]

    if rule.link_url == CautionFlagRule::SCHOOL_URL
      cols_map_update.pop
      str = <<-SQL
          UPDATE #{table_name} SET #{cols_to_update(cols_map_update)}, link_url = #{Institution.table_name}.insturl
          FROM #{CautionFlagRule.table_name}, #{Institution.table_name}
          WHERE #{CautionFlagRule.table_name}.id = #{rule.id}
          AND #{table_name}.id in (#{ids.join(',')})
          AND #{Institution.table_name}.id = #{table_name}.institution_id
      SQL
    else
      str = <<-SQL
            UPDATE #{table_name} SET #{cols_to_update(cols_map_update)}
            FROM #{CautionFlagRule.table_name}
            WHERE #{CautionFlagRule.table_name}.id = #{rule.id}
            AND #{table_name}.id in (#{ids.join(',')})
      SQL
    end

    CautionFlag.connection.update(str)
  end
end
