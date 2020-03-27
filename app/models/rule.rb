# frozen_string_literal: true

class Rule < ApplicationRecord
  RULE_TABLES = [CautionFlag.table_name].freeze

  MATCHERS = {
    has: 'has'
  }.freeze

  ACTIONS = {
    update: 'update'
  }.freeze

  validates :rule_table, :matcher, :action, presence: true

  validates :action, inclusion: { in: ACTIONS.values }
  validates :matcher, inclusion: { in: MATCHERS.values }
  validates :rule_table, inclusion: { in: RULE_TABLES }

  def self.create_engine
    Wongi::Engine.create
  end

  def self.apply_rules(engine, table_name, cols_to_update)
    Rules.where(rule_table: table_name).find_each do |rule|
      type_matcher = nil

      case rule.matcher
      when MATCHERS[:has]
        type_matcher = matcher?(engine, rule)
      end

      next if type_matcher.blank?

      type_ids = []
      type_matcher.tokens.each do |token|
        type_ids << token.wme[:object].id
      end

      case rule.action
      when ACTIONS[:update]
        apply_update(rule, cols_to_update)
      end
    end
  end

  def self.matcher?(engine, rule)
    engine.rule `type_rule_#{rule.id}` do
      forall do
        has rule.subject || :_, rule.predicate || :_, rule.object || :_
      end
    end
  end

  def self.apply_update(rule, cols_to_update)
    str = <<-SQL
          UPDATE #{rule.rule_table} SET #{cols_to_update}
          FROM #{rule.rule_table}_rules as rule_type
          WHERE rule_type.rule_id = #{rule.id}
          AND #{rule.rule_table}.id in (#{type_ids})
    SQL

    puts str

    # ActiveRecord.connection.update(str)
  end
end
