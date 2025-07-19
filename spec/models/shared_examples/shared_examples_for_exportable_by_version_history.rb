# frozen_string_literal: true

RSpec.shared_examples 'an exportable model by version history' do
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }
  let(:source_klass) { described_class.source_klass }
  let(:source_factory) { source_klass.name.underscore.to_sym }
  let(:current_year) { Time.zone.now.year }

  before do
    v2022 = create(:version, :production, :from_year, year: 2022)
    create_list(factory_name, 5, year: 2022, version: v2022)

    v2023 = create(:version, :production, :from_year, year: 2023)
    create_list(factory_name, 5, year: 2023, version: v2023)

    v2024 = create(:version, :production, :from_year, year: 2024)
    create_list(factory_name, 5, year: 2024, version: v2024)

    live_version = create(:version, :production, :from_year, year: current_year)
    create_list(source_factory, 5, version: live_version)
  end

  describe '.export_version_history' do
    let(:mapping) { source_klass::CSV_CONVERTER_INFO }
    let(:col_sep) { Common::Shared.file_type_defaults(described_class.name)[:col_sep] }

    it 'raises NotImplementedError unless klass included in VERSION_HISTORY_EXPORTABLE_TABLES' do
      expect { described_class.export_version_history(2022, current_year) }.not_to raise_error(NotImplementedError)
    end

    def check_headers(header_row)
      expect(header_row).to match_array([*mapping.keys, 'updated_by', 'date'])
    end

    def check_attributes_from_records(rows:, header_row:, records:)
      records.each.with_index do |record, i|
        attributes = {}

        version_columns = rows[i].pop(2)
        rows[i].each.with_index do |value, j|
          header = Common::Shared.convert_csv_header(header_row[j])
          attributes[mapping[header][:column]] = value
        end
        version = Version.new(
          completed_at: Time.zone.parse(version_columns[1]),
          user: User.new(email: version_columns[0])
        )
        csv_record = described_class.new(**attributes, version: version)
        csv_test_attributes = attributes_from(csv_record, version)
        test_attributes = attributes_from(record)

        expect(csv_test_attributes).to eq(test_attributes)
      end
    end

    def attributes_from(record, version = record.version)
      # Except name because issues with sequence when running tests in parallel
      excepted = %w[id name version version_id created_at updated_at]
      record.attributes.except(*excepted).merge({ updated_by: version.user.email,
                                                  date: version.completed_at.to_fs(:db) })
    end

    it 'generates a change log for the record over the course of given year range' do
      start_year = 2023
      version_history = described_class.export_version_history(start_year, current_year)
      rows = version_history.split("\n")
      header_row = rows.shift.split(col_sep)
      rows = CSV.parse(rows.join("\n"), col_sep: col_sep)
      check_headers(header_row)

      live_data = source_klass.all.to_a
      archived_data = described_class.where('created_at >= ?', Time.zone.local(start_year, 1, 1))
                                     .order(created_at: :desc)
                                     .to_a
      records = live_data.concat(archived_data)
      check_attributes_from_records(rows:, header_row:, records:)
    end
  end
end
