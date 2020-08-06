# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CautionFlagTemplate do
  describe 'as a parent class' do
    CautionFlagTemplate.descendants.each do |template|
      it "requires #{template.name} subclass to define required constants" do
        expect(template::NAME).to be_present
        expect(template::REASON_SQL).to be_present
        expect(template::TITLE).to be_present
        expect(template::DESCRIPTION).to be_present
        expect(template::LINK_TEXT).to be_present
        expect(template::LINK_URL).to be_present
      end
    end
  end
end
