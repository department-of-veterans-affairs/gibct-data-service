require 'rails_helper'

RSpec.describe 'accreditation_type_keywords/index', type: :view do
  before do
    create(:accreditation_type_keyword)
    create(:accreditation_type_keyword, :accreditation_type_regional)
    # rubocop:disable RSpec/InstanceVariable
    @accreditation_type = 'regional'
    @accreditation_type_keywords = AccreditationTypeKeyword.where(accreditation_type: @accreditation_type)
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'shows a title for accreditation keywords' do
    render
    expect(rendered).to match(/Keywords for regional accreditation/)
  end

  it 'renders a list of accreditation type keywords' do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new('middle'.to_s), count: 1
    assert_select cell_selector, text: Regexp.new('northwest'.to_s), count: 1
  end

  it 'renders a delete link for all accreditation type keywords' do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new('Delete'.to_s), count: 2
  end

  it 'renders an add link' do
    render
    expect(rendered).to match(/Add Keyword/)
  end
end
