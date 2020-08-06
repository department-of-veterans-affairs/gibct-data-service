# frozen_string_literal: true

class Sec702CautionFlag < CautionFlag
  def source
    'Sec702'
  end

  def title
    <<-SQL
      'School isn''t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits'
    SQL
  end

  def description
    <<-SQL
      'This school isn''t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits because it doesn''t comply with Section 702. This law requires public universities to offer recent Veterans and other covered individuals in-state tuition, regardless of their state residency.'
    SQL
  end

  def link_text
    <<-SQL
      'Learn more about Section 702 requirements'
    SQL
  end

  def link_url
    <<-SQL
      'https://www.benefits.va.gov/gibill/docs/factsheets/section_702_factsheet.pdf'
    SQL
  end
end
