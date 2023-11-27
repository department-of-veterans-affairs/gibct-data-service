# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accreditation_type_keywords/_form.html.erb', type: :view do
  before do
    assign(
      :accreditation_type_keyword,
      AccreditationTypeKeyword.new(accreditation_type: 'hybrid', keyword_match: 'northwest')
    )
  end

  it 'renders new accreditation keyword form' do
    render

    assert_select 'form[action=?][method=?]', accreditation_type_keywords_path, 'post' do
      assert_select 'input[name=?]', 'accreditation_type_keyword[accreditation_type]'
      assert_select 'input[name=?]', 'accreditation_type_keyword[keyword_match]'
    end
  end
end
