# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  belongs_to :institution

  def self.map(version_id)
    engine = Rule.create_engine
    cols_to_update = '(title, description, link_text, link_url)'
    where(version_id: version_id).each do |cf|
      engine << [cf.source, cf.reason, cf]
    end
    Rule.apply_rules(engine, table_name, cols_to_update)
  end

end
