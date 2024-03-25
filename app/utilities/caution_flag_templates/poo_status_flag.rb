# frozen_string_literal: true

require_relative 'caution_flag_template'

class CautionFlagTemplates::PooStatusFlag < CautionFlagTemplates::CautionFlagTemplate
  NAME = 'Poo_Status_Susp'
  TITLE = 'School may not be able to accept new GI Bill students'
  DESCRIPTION = 'This school currently doesn\'\'t meet the approval criteria for receiving GI Bill funds and has been '\
  'suspended. The suspension doesn\'\'t impact current students.'
  LINK_TEXT = nil
  LINK_URL = nil
end
