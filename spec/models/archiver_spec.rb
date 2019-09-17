# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archiver, type: :model do
  describe '#tables' do
    before(:each) do
      create :weam, :institution_builder
      create :crosswalk, :institution_builder
    end

    context 'archive tables' do
      it 'source and archive tables match' do
        Archiver::ARCHIVE_TYPES.each do |archivable|
          archivable[:source].column_names.each do |column|
            expect(ActiveRecord::Base.connection.column_exists?(archivable[:archive].table_name, column)).to be_truthy
          end
        end
      end
    end
  end
end
