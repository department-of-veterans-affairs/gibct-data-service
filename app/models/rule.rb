# frozen_string_literal: true

class Rule < ApplicationRecord
  RULE_NAMES = [CautionFlag.name].freeze

  MATCHERS = {
    has: 'has'
  }.freeze

  validates :rule_name, :matcher, presence: true

  validates :matcher, inclusion: { in: MATCHERS.values }
  validates :rule_name, inclusion: { in: RULE_NAMES }

  def self.create_engine
    Wongi::Engine.create
  end

  def self.apply_rule(engine, rule)
    rule_matcher = nil

    case rule.matcher
    when MATCHERS[:has]
      rule_matcher = matcher_has(engine, rule)
    end

    subjects = []
    return subjects if rule_matcher.blank?

    rule_matcher.tokens.each do |token|
      subjects << token.wme[:subject]
    end
    subjects
  end

  def self.matcher_has(engine, rule)
    object = rule.object.kind_of?(String) ? rule.object.downcase : rule.object

    # Use rule's values or use wildcard character
    engine.rule "type_rule_#{rule.id}" do
      forall do
        has rule.subject || :_, rule.predicate.to_sym || :_, object || :_
      end
    end
  end
end
