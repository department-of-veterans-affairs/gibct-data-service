# frozen_string_literal: true

class SettlementCautionFlag < CautionFlag
  def source
    'Settlement'
  end

  def reason_sql
    <<-SQL
      va_caution_flags.settlement_description
    SQL
  end

  def title
    <<-SQL
      va_caution_flags.settlement_title
    SQL
  end

  def description
    <<-SQL
      va_caution_flags.settlement_description
    SQL
  end

  def link_url
    <<-SQL
      va_caution_flags.settlement_link
    SQL
  end

  def flag_date
    <<-SQL
      va_caution_flags.settlement_date
    SQL
  end

end
