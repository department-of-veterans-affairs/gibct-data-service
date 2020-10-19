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

    load_options = Common::Shared.file_type_defaults(described_class.name, options)

    file_options = { liberal_parsing: load_options[:liberal_parsing],
                     sheets: [{ klass: described_class, skip_lines: load_options[:skip_lines].try(:to_i) }] }

    context 'with an error-free csv file' do
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

    context 'with a problematic csv file' do
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

    # describe 'header checking' do
    #   it 'has no missing or extra headers for a normal csv' do
    #     upload.check_for_headers
    #
    #     expect(upload.missing_headers).to be_empty
    #     expect(upload.extra_headers).to be_empty
    #   end
    #
    #   it 'has missing headers when a csv column is missing' do
    #     upload = build :upload, csv_name: 'weam_missing_column.csv'
    #     upload.check_for_headers
    #
    #     expect(upload.missing_headers).not_to be_empty
    #     expect(upload.extra_headers).to be_empty
    #   end
    #
    #   it 'has extra headers when a csv column is added' do
    #     upload = build :upload, csv_name: 'weam_extra_column.csv'
    #     upload.check_for_headers
    #
    #     expect(upload.missing_headers).to be_empty
    #     expect(upload.extra_headers).not_to be_empty
    #   end
    #
    #   context 'with insufficient information' do
    #     it 'has no missing or extra headers if upload_file not valid' do
    #       upload.upload_file = nil
    #       upload.check_for_headers
    #
    #       expect(upload.missing_headers).to be_empty
    #       expect(upload.extra_headers).to be_empty
    #     end
    #
    #     it 'has no missing or extra headers if csv_type not valid' do
    #       upload.csv_type = nil
    #       upload.check_for_headers
    #
    #       expect(upload.missing_headers).to be_empty
    #       expect(upload.extra_headers).to be_empty
    #     end
    #
    #     it 'has no missing or extra headers if skip_lines is not valid' do
    #       upload.skip_lines = nil
    #       upload.check_for_headers
    #
    #       expect(upload.missing_headers).to be_empty
    #       expect(upload.extra_headers).to be_empty
    #     end
    #   end
    # end

    # describe 'set_col_sep' do
    #   it 'sets col_sep to comma when csv first line' do
    #     first_line = 'a,b,c'
    #     upload = build :upload
    #     upload.send(:set_col_sep, first_line)
    #     expect(upload.col_sep).to eq(',')
    #   end
    #
    #   it 'sets col_sep to pipe when pipe delimited first line and contains a comma in a column' do
    #     first_line = 'a|,b|c'
    #     upload = create :upload
    #     upload.send(:set_col_sep, first_line)
    #     expect(upload.col_sep).to eq('|')
    #   end
    #
    #   it 'raises error when neither comma or pipe are found' do
    #     first_line = 'a/b\c'
    #     upload = create :upload
    #     error_message = 'Unable to determine column separators, valid separators equal "|" and ","'
    #     expect { upload.send(:set_col_sep, first_line) }.to raise_error(StandardError, error_message)
    #   end
    # end
  end
end
