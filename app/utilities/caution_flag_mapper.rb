include Wongi::Engine::DSL

class CautionFlagMapper

  def self.map(version_id)

    engine = Wongi::Engine.create
    type = 'caution_flags'
    cols_to_update = '(title, description, link_text, link_url)'
    CautionFlag.where(version_id: version_id).each do |cf|
      engine << [cf.source, cf.reason, cf]
    end
    apply_rules(engine, type, cols_to_update)
  end

  def self.apply_rules(engine, type, cols_to_update)
    Rules.where(type: type).each do |rule|
      type_rule = nil
      
      case rule.matcher
      when 'has'
        type_rule = engine.rule `type_rule_#{rule.id}` do
          forall {
            has rule.subject || :_, rule.predicate || :_, rule.object || :_
          }
        end
      end

      type_ids = []
      type_rule&.tokens&.each do |token|
        type_ids << token.wme[:object].id
      end

      str = <<-SQL
          UPDATE #{rule.type} SET #{cols_to_update}
          FROM #{rule.type}_rules as rule
          WHERE rule.id = #{rule.id}
          AND #{rule.type}.id in (#{type_ids})
      SQL

      # ActiveRecord.connection.update(str)
    end
  end
end