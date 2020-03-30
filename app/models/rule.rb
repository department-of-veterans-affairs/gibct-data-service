# frozen_string_literal: true

class Rule < ApplicationRecord
  RULE_NAMES = [CautionFlag.name].freeze

  MATCHERS = {
    has: 'has'
  }.freeze

  ACTIONS = {
    update: 'update'
  }.freeze

  validates :rule_name, :matcher, :action, presence: true

  validates :action, inclusion: { in: ACTIONS.values }
  validates :matcher, inclusion: { in: MATCHERS.values }
  validates :rule_name, inclusion: { in: RULE_NAMES }

  def self.create_engine
    Wongi::Engine.create
  end

  def self.apply_rules(engine, rule_name)
    where(rule_name: rule_name).find_each do |rule|
      rule_matcher = nil

      case rule.matcher
      when MATCHERS[:has]
        rule_matcher = matcher?(engine, rule)
      end

      next if rule_matcher.blank?

      rule_ids = []
      rule_matcher.tokens.each do |token|
        rule_ids << token.wme[:object].id
      end

      case rule.action
      when ACTIONS[:update]
        apply_update(rule, rule_ids)
      end
    end
  end

  def self.matcher?(engine, rule)
    engine.rule "type_rule_#{rule.id}" do
      forall do
        has rule.subject || :_, rule.predicate || :_, rule.object || :_
      end
    end
  end

  def self.apply_update(rule, rule_ids)
    updated_table = rule.rule_name.underscore.pluralize

    rule_klass = "#{rule.rule_name}Rule".constantize
    cols_to_update = rule_klass::COLS_USED_IN_UPDATE.map(&:to_s).map { |col| %("#{col}" = #{rule_klass.table_name}.#{col}) }.join(', ')

    str = <<-SQL
          UPDATE #{updated_table} SET #{cols_to_update}
          FROM #{rule_klass.table_name}
          WHERE #{rule_klass.table_name}.rule_id = #{rule.id}
          AND #{updated_table}.id in (#{rule_ids.join(',')})
    SQL

    rule_klass.connection.update(str)
  end
end
