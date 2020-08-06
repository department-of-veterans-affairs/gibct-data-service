# frozen_string_literal: true

class MouCautionFlag
  NAME = 'Mou'
  REASON = 'DoD Probation For Military Tuition Assistance'
  REASON_SQL = <<-SQL
      '#{REASON}'
  SQL
  TITLE = 'School is on Military Tuition Assistance probation'
  DESCRIPTION = 'This school is on Department of Defense (DOD) probation for Military Tuition Assistance (TA).'
  LINK_TEXT = 'Learn about DOD probation'
  LINK_URL = 'https://www.dodmou.com/Home/Faq'
end
