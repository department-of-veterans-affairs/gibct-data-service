# frozen_string_literal: true

require_relative 'caution_flag_template'

class MouCautionFlag < CautionFlagTemplate
  NAME = Mou.name
  TITLE = 'School is on Military Tuition Assistance probation'
  DESCRIPTION = 'This school is on Department of Defense (DOD) probation for Military Tuition Assistance (TA).'
  LINK_TEXT = 'Learn about DOD probation'
  LINK_URL = 'https://www.dodmou.com/Home/Faq'
end
