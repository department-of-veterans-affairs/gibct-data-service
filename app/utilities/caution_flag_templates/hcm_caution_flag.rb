# frozen_string_literal: true

class HcmCautionFlag
  NAME = 'Hcm'
  REASON_SQL = <<-SQL
     hcm_list.reasons
  SQL
  TITLE = 'School placed on Heightened Cash Monitoring'
  DESCRIPTION = 'The Department of Education has placed this '\
                'school on Heightened Cash Monitoring because of financial or federal compliance issues.'
  LINK_TEXT = 'Learn more about Heightened Cash Monitoring'
  LINK_URL = 'https://studentaid.ed.gov/sa/about/data-center/school/hcm'
end
