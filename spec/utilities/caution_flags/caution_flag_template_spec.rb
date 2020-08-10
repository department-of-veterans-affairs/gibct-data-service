# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../app/utilities/caution_flag_templates/caution_flag_template'
require_relative '../../../app/utilities/caution_flag_templates/accreditation_caution_flag'
require_relative '../../../app/utilities/caution_flag_templates/hcm_caution_flag'
require_relative '../../../app/utilities/caution_flag_templates/sec702_caution_flag'
require_relative '../../../app/utilities/caution_flag_templates/mou_caution_flag'

RSpec.describe CautionFlagTemplate do
  describe 'as a parent class' do
    described_class.descendants.each do |template|
      it "requires #{template.name} templates to define required constants" do
        expect(template::NAME).to be_present
        expect(template::TITLE).to be_present
        expect(template::DESCRIPTION).to be_present
        expect(template::LINK_TEXT).to be_present
        expect(template::LINK_URL).to be_present
      end
    end
  end
end
