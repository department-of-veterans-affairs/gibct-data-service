# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution

  def self.map(version_id)
    engine = Rule.create_engine
    where(version_id: version_id).find_each do |cf|
      engine << [cf.source, cf.reason, cf]
    end
    Rule.apply_rules(engine, name)
  end
end
