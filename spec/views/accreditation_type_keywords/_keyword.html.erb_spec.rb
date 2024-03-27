# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accreditation_type_keywords/_keyword.html.erb', type: :view do
  it 'renders an accreditation keyword row' do
    # after fighting with this for a while, it seems like this is what works.
    accreditation_type_keyword = AccreditationTypeKeyword.new(accreditation_type: 'hybrid', keyword_match: 'northwest')
    render('keyword', { accreditation_type_keyword: accreditation_type_keyword })

    expect(rendered).to have_css('tr')
    expect(rendered).to have_css('td', text: 'northwest')
    expect(rendered).to have_link 'Delete'
  end
end
