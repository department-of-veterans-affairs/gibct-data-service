# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archiver, type: :model do
  describe '::ARCHIVE_TYPES_BY_PARENT_ID' do
    context 'when mapped' do
      Archiver::ARCHIVE_TYPES_BY_PARENT_ID.each do |archivable|
        it "#{archivable[:source].table_name} and #{archivable[:archive].table_name} map correctly" do
          archivable[:source].column_names.each do |column|
            expect(ActiveRecord::Base.connection).to be_column_exists(archivable[:archive].table_name, column)
          end
        end
      end
    end
  end
  describe '::ARCHIVE_TYPES_BY_VERSION_ID' do
    context 'when mapped' do
      Archiver::ARCHIVE_TYPES_BY_VERSION_ID.each do |archivable|
        it "#{archivable[:source].table_name} and #{archivable[:archive].table_name} map correctly" do
          archivable[:source].column_names.each do |column|
            expect(ActiveRecord::Base.connection).to be_column_exists(archivable[:archive].table_name, column)
          end
        end
      end
    end
  end
end
