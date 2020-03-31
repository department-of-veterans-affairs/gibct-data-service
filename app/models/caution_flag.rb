# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution

  COLS_MAP_UPDATE = %i[
    title description link_text link_url
  ].freeze

  def self.map(version_id)
    puts "START #{Time.now}"
    engine = Rule.create_engine

    predicates = Rule.distinct.pluck(:predicate)
    caution_flags = where(version_id: version_id)

    CautionFlagRule.all.find_each do |cf_rule|
      caution_flags.each do |cf|
        predicates.each do |predicate|
          engine << [cf.id, predicate.to_sym, cf[predicate.to_sym]]
        end
      end

      subjects = Rule.apply_rule(engine, cf_rule.rule)
      apply_update(cf_rule, subjects) unless subjects.empty?
    end
    puts "END #{Time.now}"
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
