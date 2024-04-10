# frozen_string_literal: true

require_relative 'caution_flag_template'

class CautionFlagTemplates::AccreditationCautionFlag < CautionFlagTemplates::CautionFlagTemplate
  NAME = AccreditationAction.name
  TITLE = 'School has an accreditation issue'
  DESCRIPTION = 'This school\'\'s accreditation has been taken away and is under appeal, '\
                'or the school has been placed on probation, because it didn\'\'t meet '\
                'acceptable levels of quality.'
  LINK_TEXT = 'Learn more about this school\'\'s accreditation'
  LINK_URL = 'http://ope.ed.gov/accreditation/'
end
