# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution

  def self.map(version_id)
    puts "START #{Time.zone.now}"
    engine = Rule.create_engine

    # Get distinct predicates
    predicates = Rule.select(:predicate).where(rule_name: CautionFlag.name).distinct.pluck(:predicate)

    # Load all caution flag rows into engine for each predicate
    where(version_id: version_id).find_each do |cf|
      predicates.map(&:to_sym).each do |predicate|
        engine << [cf.id, predicate, cf[predicate]]
      end
    end

    # Apply rules for rules that use source as a predicate as these are more general
    CautionFlagRule.includes(:rule)
                   .where('rules.predicate = ?', 'source').references(:rule).find_each do |cf_rule|
      subjects = Rule.apply_rule(engine, cf_rule.rule)
      apply_update(cf_rule, subjects) unless subjects.empty?
    end

    # Apply rules for rules that use reason as a predicate as these are more specific
    CautionFlagRule.includes(:rule)
                   .where('rules.predicate = ?', 'reason').references(:rule).find_each do |cf_rule|
      subjects = Rule.apply_rule(engine, cf_rule.rule)
      apply_update(cf_rule, subjects) unless subjects.empty?
    end

    puts "END #{Time.zone.now}"
  end

  def self.apply_update(rule, ids)
    cols_map_update = %i[
      title description link_text link_url
    ]
    cols_to_update = cols_map_update.map(&:to_s)
                                    .map { |col| %(#{col} = #{CautionFlagRule.table_name}.#{col}) }.join(', ')

    str = <<-SQL
          UPDATE #{table_name} SET #{cols_to_update}
          FROM #{CautionFlagRule.table_name}
          WHERE #{CautionFlagRule.table_name}.id = #{rule.id}
          AND #{table_name}.id in (#{ids.join(',')})
    SQL

    CautionFlag.connection.update(str)
  end
end
