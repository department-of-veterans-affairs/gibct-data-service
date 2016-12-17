# frozen_string_literal: true
RSpec.shared_examples 'a savable model' do
  describe 'attributes' do
    subject { described_class.new }

    it '#skip_uniquenes' do
      expect(subject).to respond_to(:skip_uniqueness)
    end
  end

  describe '#save_for_bulk_insert' do
    subject { build described_class.name.underscore.to_sym }

    it 'assigns true to #skip_uniquness with a valid model' do
      subject.save_for_bulk_insert!
      expect(subject.skip_uniqueness).to be_truthy
    end

    it 'calls the save method' do
      expect(subject).to receive(:save!)
      subject.save_for_bulk_insert!
    end
  end

  describe '::permit_csv_row_before_save' do
    it 'returns a boolean' do
      expect(described_class.permit_csv_row_before_save).to be_truthy.or be_falsey
    end
  end
end
