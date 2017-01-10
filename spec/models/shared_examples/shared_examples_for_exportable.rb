# frozen_string_literal: true
RSpec.shared_examples 'an exportable model' do |options|
  let(:csv_file) { File.new(Rails.root.join('spec/fixtures', "#{name}.csv")) }
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }

  def convert_csv_row_to_model_attributes(headers, row)
    attributes_to_create_record = row.map.with_index do |col, i|
      column_name = described_class::MAP[headers[i]].keys.first
      attributes_to_create_record[column_name] = col
    end

    record = described_class.new(attributes_to_create_record)
    record.derive_dependent_columns

    record.attributes.except('id', 'created_at', 'updated_at')
  end


  describe "#{described_class}::MAP" do
    it 'must be defined for exportable classes' do
      expect(described_class::MAP).not_to be_nil
    end
  end

  describe "#{described_class}.export" do
    subject { described_class.export }

    let(:capitalized_headers) do
      described_class::MAP.keys.map { |header| header.split('_').map(&:capitalize).join(' ') }.join(',')
    end

    before(:each) do
      described_class.load(csv_file, options)
    end

    it 'capitalizes the original headers' do
      headers_from_csv = subject.split("\n").first
      headers_from_map = csv_map.keys.map do |header|
        header.split('_').map(&:capitalize).join(' ') }.join(',')
      end

      expect(headers_from_csv).to eq(headers_from_map)
    end

    it 'reproduces each table record as a row' do

      csv_headers = rows.split("\n").shift.split(',').map { |header| header.tr(' ', '_').downcase }

      # attributes_from_csv = CSV.parse(rows).map { |row| convert_csv_row_to_model_attributes(csv_headers, row) }

      # described_class.find_each.with_index do |record, i|
      #   record = record.attributes.except('id', 'created_at', 'updated_at')
      #   expect(record).to eq(attributes_from_csv[i])
      # end
    end
  end
end
