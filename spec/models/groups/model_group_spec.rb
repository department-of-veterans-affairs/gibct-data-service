# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelGroup do
  describe 'as a parent class' do
    described_class.descendants.each do |record|
      it "requires #{record.name} subclass to define required constants" do
        expect(record::FILE_TYPES).to be_present
      end
    end
  end
end
