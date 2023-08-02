# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboards/index', type: :view do
  before do # set the instance variables from the controller before the view is rendered or tests fail
    @production_versions = Version.production.newest.includes(:user).limit(1)
    @preview_versions = Version.preview.newest.includes(:user).limit(1)
    @latest_uploads = Upload.since_last_version
  end

  it 'does not show the button if there are no failed fetches' do
    create(:upload, :valid_upload)
    render
    expect(rendered).not_to match(/Enable locked Fetches/)
  end

  it 'shows the button if there are failed fetches' do
    create(:upload, :failed_upload)
    render
    expect(rendered).to match(/Enable locked Fetches/)
  end
end
