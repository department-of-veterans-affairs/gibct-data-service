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
    load_options = default_options.each_with_object({}) { |(k, v), o| o[k.to_sym] = v; }.merge(options)

    context 'with an error-free csv file' do
      it 'deletes the old table content' do
        expect { described_class.load(csv_file, load_options) }.to change(described_class, :count).from(5).to(2)
      end

      it 'loads the table' do
        results = described_class.load(csv_file, load_options)

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(2)
      end
    end

    context 'with a problematic csv file' do
      let(:csv_rows) { 2 }

      it 'does not load invalid records into the table' do
        results = described_class.load(csv_file_invalid, load_options)

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(1)
      end

      it 'does not delete previous record if upload is invalid' do
        results = described_class.load(csv_file_invalid, load_options)
        expect { described_class.load(csv_file_invalid, load_options) }.to_not change(described_class, :count).from(1)
      end  
    end
  end
end
