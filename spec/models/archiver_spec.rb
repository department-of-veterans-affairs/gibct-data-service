# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archiver, type: :model do
  describe '::ARCHIVE_TYPES' do
    context 'when mapped' do
      Archiver::ARCHIVE_TYPES.each do |archivable|
        it "#{archivable[:source].table_name} and #{archivable[:archive].table_name} map correctly" do
          archivable[:source].column_names.each do |column|
            expect(ActiveRecord::Base.connection.column_exists?(archivable[:archive].table_name, column)).to be_truthy
          end
        end
      end
    end
  end
end
