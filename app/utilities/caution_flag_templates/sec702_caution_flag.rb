# frozen_string_literal: true

require_relative 'caution_flag_template'

class Sec702CautionFlag < CautionFlagTemplate
  NAME = 'Sec702'
  TITLE = 'School isn\'\'t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits'
  DESCRIPTION = 'This school isn\'\'t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty '\
                'benefits because it doesn\'\'t comply with Section 702. This law requires public universities '\
                'to offer recent Veterans and other covered individuals in-state tuition, regardless of their '\
                'state residency.'
  LINK_TEXT = nil
  LINK_URL = nil
end
