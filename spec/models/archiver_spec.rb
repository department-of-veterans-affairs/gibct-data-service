# frozen_string_literal: true

require 'rails_helper'

describe '::ARCHIVE_TYPES' do
  context 'when mapped' do
    Archiver::ARCHIVE_TYPES.each do |archivable|
      it "#{archivable[:source].table_name} and #{archivable[:archive].table_name} map correctly" do
        archivable[:source].column_names.each do |column|
          expect(ActiveRecord::Base.connection).to be_column_exists(archivable[:archive].table_name, column)
        end
      end
    end
  end
end
