# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportableRecord do
  describe 'as a parent class' do
    described_class.descendants.each do |record|
      it "requires #{record.name} subclass to define required constants" do
        expect(record::CSV_CONVERTER_INFO).to be_present
      end

      it "requires #{record.name} CSV_CONVERTER_INFO to use underscores in keys" do
        record::CSV_CONVERTER_INFO.each_key do |key|
          expect(key).to be_a(String)
        end
      end
    end
  end
end
