# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution

  COLS_MAP_UPDATE = %i[
    title description link_text link_url
  ].freeze

  def self.map(version_id)
    engine = Rule.create_engine

    CautionFlagRule.all.find_each do |cf_rule|
      predicate = cf_rule.rule.predicate.to_sym

      where(version_id: version_id, source: cf_rule.source).find_each do |cf|
        engine << [cf.id, predicate, cf[predicate]]
      end

      subjects = Rule.apply_rule(engine, cf_rule.rule)
      apply_update(cf_rule, subjects) unless subjects.empty?
    end
  end

  def self.apply_update(rule, ids)
    cols_to_update = COLS_MAP_UPDATE.map(&:to_s)
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
