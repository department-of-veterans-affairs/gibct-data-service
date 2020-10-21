# frozen_string_literal: true

RSpec.shared_examples 'an exportable model by version' do
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }
  let(:mapping) { described_class::CSV_CONVERTER_INFO }
  let(:version) { create :version, :production, id: 40_000 }

  before do
    create_list factory_name, 10, version_id: version.id
  end

  describe 'when exporting by version' do
    # Pull the default CSV options to be used
    default_options = Rails.application.config.csv_defaults[described_class.name] ||
                      Rails.application.config.csv_defaults['generic']

    def check_attributes_from_records(rows, header_row)
      described_class.find_each.with_index do |record, i|
        attributes = {}

        rows[i].each.with_index do |value, j|
          header = Common::Shared.convert_csv_header(header_row[j])
          attributes[mapping[header][:column]] = value
        end
        csv_record = described_class.new(attributes)
        csv_record.derive_dependent_columns if csv_record.respond_to?(:derive_dependent_columns)

        ignored_attributes = %w[id version created_at updated_at csv_row version_id institution_search]
        csv_test_attributes = csv_record.attributes.except(*ignored_attributes)
        test_attributes = record.attributes.except(*ignored_attributes)

        test_attributes['ope'] = "\"#{test_attributes['ope']}\"" if test_attributes['ope']

        expect(csv_test_attributes).to eq(test_attributes)
      end
    end

    it 'creates a string representation of a csv_file' do
      rows = described_class.export_by_version(version.number).split("\n")
      header_row = rows.shift.split(default_options['col_sep']).map(&:downcase)
      rows = CSV.parse(rows.join("\n"), col_sep: default_options['col_sep'])
      check_attributes_from_records(rows, header_row)
    end
  end
end
