# frozen_string_literal: true

RSpec.shared_examples 'an exportable model' do |options|
  subject { described_class.export }

  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }
  let(:csv_file) { "spec/fixtures/#{name}.csv" }
  let(:mapping) { described_class::CSV_CONVERTER_INFO }

  describe 'when exporting' do
    load_options = Common::Shared.file_type_defaults(described_class.name, options)

    file_options = { liberal_parsing: load_options[:liberal_parsing],
                     sheets: [{ klass: described_class, skip_lines: load_options[:skip_lines].try(:to_i),
                                clean_rows: load_options[:clean_rows] }] }

    before do
      described_class.load_with_roo(csv_file, file_options)
    end

    def check_attributes_from_records(rows, header_row)
      described_class.find_each.with_index do |record, i|
        attributes = {}

        rows[i].each.with_index do |value, j|
          header = Common::Shared.convert_csv_header(header_row[j])
          attributes[mapping[header][:column]] = value
        end
        csv_record = described_class.new(attributes)
        csv_record.derive_dependent_columns if csv_record.respond_to?(:derive_dependent_columns)
        if factory_name == :weam
          csv_test_attributes = csv_record.attributes.except('id', 'version', 'created_at', 'updated_at', 'csv_row', \
                                                             'latitude', 'longitude')
          test_attributes = record.attributes.except('id', 'version', 'created_at', 'updated_at', 'csv_row', \
                                                     'latitude', 'longitude')
        else
          csv_test_attributes = csv_record.attributes.except('id', 'version', 'created_at', 'updated_at', 'csv_row')
          test_attributes = record.attributes.except('id', 'version', 'created_at', 'updated_at', 'csv_row')
        end
        deconvert(test_attributes)
        expect(csv_test_attributes).to eq(test_attributes)
      end
    end

    def deconvert(test_attributes)
      test_attributes['ope'] = "\"#{test_attributes['ope']}\"" if test_attributes['ope']
      if test_attributes['ojt_app_type']
        test_attributes['ojt_app_type'] = Converters::OjtAppTypeConverter.deconvert(test_attributes['ojt_app_type'])
      end
    end

    it 'creates a string representation of a csv_file' do
      rows = subject.split("\n")
      col_sep = Common::Shared.file_type_defaults(described_class.name, options)[:col_sep]
      header_row = rows.shift.split(col_sep).map(&:downcase)
      rows = CSV.parse(rows.join("\n"), col_sep: col_sep)
      check_attributes_from_records(rows, header_row)
    end
  end
end
