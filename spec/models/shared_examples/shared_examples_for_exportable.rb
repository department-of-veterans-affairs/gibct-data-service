# frozen_string_literal: true
RSpec.shared_examples 'an exportable model' do |options|
  let(:csv_file) { File.new(Rails.root.join('spec/fixtures', "#{name}.csv")) }
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }

  describe "#{described_class}::MAP" do
    it 'must be defined for exportable classes' do
      expect(described_class::MAP).not_to be_nil
    end
  end

  describe "#{described_class}.export" do
    let(:headers) { described_class::MAP.keys.map { |header| header.split(' ').map(&:capitalize).join(' ') }.join(',') }
    let(:rows) { described_class.export.split("\n") }

    before(:each) do
      described_class.load(csv_file, options)
    end

    it 'capitalizes the original headers' do
      expect(rows.first).to eq(headers)
    end

    it 'reproduces each table record as a row' do
      converters = described_class::MAP.values

      described_class.all.each_with_index do |record, n|
        csv_columns = rows[n + 1].split(',').map { |s| s.blank? ? nil : s }

        converters.each_with_index do |converter, i|
          column_name = converter.keys.first
          converter_class = converter[column_name]

          expect(record[column_name]).to eq(converter_class.convert(csv_columns[i]))
        end
      end
    end
  end
end
