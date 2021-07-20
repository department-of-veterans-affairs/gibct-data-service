# frozen_string_literal: true

RSpec.shared_examples 'a loadable model' do |options|
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }
  file_ext = options[:file_ext] || 'csv'

  before do
    create :user
    create_list factory_name, 5
  end

  describe 'when loading' do
    let(:csv_file) { "./spec/fixtures/#{name}.#{file_ext}" }
    let(:csv_file_invalid) { "./spec/fixtures/#{name}_invalid.#{file_ext}" }
    let(:csv_file_missing_column) { "./spec/fixtures/#{name}_missing_column.#{file_ext}" }
    let(:user) { User.first }

    load_options = Common::Shared.file_type_defaults(described_class.name, options)

    file_options = { liberal_parsing: load_options[:liberal_parsing],
                     sheets: [{ klass: described_class, skip_lines: load_options[:skip_lines].try(:to_i),
                                clean_rows: load_options[:clean_rows] }] }

    context "with an error-free #{file_ext} file" do
      it 'deletes the old table content' do
        expect { described_class.load_with_roo(csv_file, file_options) }
          .to change(described_class, :count).from(5).to(2)
      end

      it 'loads the table' do
        results = described_class.load_with_roo(csv_file, file_options).first[:results]

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(2)
      end
    end

    context "with a problematic #{file_ext} file" do
      let(:csv_rows) { 2 }

      it 'does not load invalid records into the table' do
        results = described_class.load_with_roo(csv_file_invalid, file_options).first[:results]

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(1)
      end

      it 'does roll back to the old table content if the upload is invalid' do
        allow(described_class).to receive(:load_with_roo).and_raise(StandardError)
        before_count = described_class.count
        expect { described_class.load_with_roo(csv_file_invalid, file_options) }.to raise_error(StandardError)
        expect(before_count).to eq(described_class.count)
      end

      it 'does roll back to the old table content if the upload loaded records are invalid' do
        allow(described_class).to receive(:load_records).and_raise(StandardError)
        before_count = described_class.count
        expect { described_class.load([], Common::Shared.file_type_defaults(described_class.name, options)) }
          .to raise_error(StandardError)
        expect(before_count).to eq(described_class.count)
      end
    end
  end
end
