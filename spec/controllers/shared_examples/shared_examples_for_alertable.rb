# frozen_string_literal: true
RSpec.shared_examples 'an alertable controller' do |controller|
  describe '::pretty_error' do
    let(:errors) { %w(error1 error2) }
    let(:label) { 'some label' }

    let(:ul) { '<ul><li>error1</li><li>error2</li></ul>' }
    let(:ul_with_label) { '<p>some label</p>' + ul }

    context 'without a label' do
      it 'formats the errors for html' do
        expect(controller.pretty_error(errors)).to eq(ul)
      end

      it 'returns an empty string when there are no errors' do
        expect(controller.pretty_error([])).to be_blank
      end
    end

    context 'with a label' do
      it 'formats the errors for html' do
        expect(controller.pretty_error(errors, label)).to eq(ul_with_label)
      end

      it 'returns an empty string when there are no errors' do
        expect(controller.pretty_error([], label)).to be_blank
      end
    end
  end
end
