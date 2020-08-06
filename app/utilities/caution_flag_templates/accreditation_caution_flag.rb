# frozen_string_literal: true

class AccreditationCautionFlag
  NAME = 'AccreditationAction'
  REASON_SQL = <<-SQL
      concat(aa.action_description, ' (', aa.justification_description, ')')
  SQL
  TITLE = 'School has an accreditation issue'
  DESCRIPTION = 'This school\'\'s accreditation has been taken away and is under appeal, '\
                'or the school has been placed on probation, because it didn\'\'t meet '\
                'acceptable levels of quality.'
  LINK_TEXT = 'Learn more about this school\'\'s accreditation'
  LINK_URL = 'http://ope.ed.gov/accreditation/'
end
