# frozen_string_literal: true

RSpec.shared_examples 'an exportable model' do |options|
  subject { described_class.export }

  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }
  let(:csv_file) { "spec/fixtures/#{name}.csv" }
  let(:mapping) { described_class::CSV_CONVERTER_INFO }

  describe 'when exporting' do
    # Pull the default CSV options to be used
    default_options = Rails.application.config.csv_defaults[described_class.name] ||
                      Rails.application.config.csv_defaults['generic']
    # Merge with provided options
    load_options = default_options.transform_keys(&:to_sym).merge(options)

    before do
      described_class.load_from_csv(csv_file, load_options)
    end

    def check_attributes_from_records(rows, header_row)
      described_class.find_each.with_index do |record, i|
        attributes = {}

        rows[i].each.with_index { |value, j| attributes[mapping[header_row[j]][:column]] = value }
        csv_record = described_class.new(attributes)
        csv_record.derive_dependent_columns if csv_record.respond_to?(:derive_dependent_columns)

        csv_test_attributes = csv_record.attributes.except('id', 'version', 'created_at', 'updated_at', 'csv_row')
        test_attributes = record.attributes.except('id', 'version', 'created_at', 'updated_at', 'csv_row')
        test_attributes['ope'] = "\"#{test_attributes['ope']}\"" if test_attributes['ope']

        expect(csv_test_attributes).to eq(test_attributes)
      end
    end

    it 'creates a string representation of a csv_file' do
      rows = subject.split("\n")
      header_row = rows.shift.split(load_options[:col_sep]).map(&:downcase)
      rows = CSV.parse(rows.join("\n"), col_sep: load_options[:col_sep])
      check_attributes_from_records(rows, header_row)
    end
  end
end
