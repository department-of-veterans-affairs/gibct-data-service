# frozen_string_literal: true

RSpec.shared_examples 'a loadable model' do |options|
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }

  before do
    create :user
    create_list factory_name, 5
  end

  describe 'when loading' do
    let(:csv_file) { "./spec/fixtures/#{name}.csv" }
    let(:csv_file_invalid) { "./spec/fixtures/#{name}_invalid.csv" }
    let(:csv_file_missing_column) { "./spec/fixtures/#{name}_missing_column.csv" }
    let(:user) { User.first }

    # Pull the default CSV options to be used
    default_options = Rails.application.config.csv_defaults[described_class.name] ||
                      Rails.application.config.csv_defaults['generic']
    # Merge with provided options
    load_options = default_options.transform_keys(&:to_sym).merge(options)

    context 'with an error-free csv file' do
      it 'deletes the old table content' do
        expect { described_class.load_from_csv(csv_file, load_options) }
          .to change(described_class, :count).from(5).to(2)
      end

      it 'loads the table' do
        results = described_class.load_from_csv(csv_file, load_options)

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(2)
      end
    end

    context 'with a problematic csv file' do
      let(:csv_rows) { 2 }

      it 'does not load invalid records into the table' do
        results = described_class.load_from_csv(csv_file_invalid, load_options)

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(1)
      end

      it 'does roll back to the old table content if the upload is invalid' do
        allow(described_class).to receive(:load_csv_file).and_raise(StandardError)
        before_count = described_class.count
        expect { described_class.load_from_csv(csv_file_invalid, load_options) }.to raise_error(StandardError)
        expect(before_count).to eq(described_class.count)
      end

      it 'does roll back to the old table content if the upload loaded records are invalid' do
        allow(described_class).to receive(:load_records).and_raise(StandardError)
        before_count = described_class.count
        expect { described_class.load_from_api([], load_options) }.to raise_error(StandardError)
        expect(before_count).to eq(described_class.count)
      end
    end
  end
end
