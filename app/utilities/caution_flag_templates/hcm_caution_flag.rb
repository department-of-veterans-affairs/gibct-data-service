# frozen_string_literal: true

require_relative 'caution_flag_template'

class CautionFlagTemplates::HcmCautionFlag < CautionFlagTemplates::CautionFlagTemplate
  NAME = Hcm.name
  TITLE = 'School placed on Heightened Cash Monitoring'
  DESCRIPTION = 'The Department of Education has placed this '\
                'school on Heightened Cash Monitoring because of financial or federal compliance issues.'
  LINK_TEXT = 'Learn more about Heightened Cash Monitoring'
  LINK_URL = 'https://studentaid.gov/data-center/school/hcm'
end
