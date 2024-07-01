# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboards/index', type: :view do
  let(:user) { create(:user) }

  before do # set the instance variables from the controller before the view is rendered or tests fail
    create(:version, :production)
    create(:version, :preview)
    @production_versions = Version.production.newest.includes(:user).limit(1)
    @preview_versions = Version.preview.newest.includes(:user).limit(1)
    @latest_uploads = Upload.since_last_version
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'shows a title for institutions with potential accreditation issues' do
    render
    expect(rendered).to match(/Institutions With No Accreditation/)
  end

  it 'does not show the unlock fetch button if there are no failed fetches' do
    create(:upload, :valid_upload)
    render
    expect(rendered).not_to match(/Enable locked Fetches/)
  end

  it 'shows the unlock fetch button if there are failed fetches' do
    create(:upload, :failed_upload)
    render
    expect(rendered).to match(/Enable locked Fetches/)
  end

  it 'does not show the generate spool file button if the user is not a spool file runner' do
    render
    expect(rendered).not_to match(/Run Daily Spool File Job/)
  end

  it 'shows the generate spool file button if the user is a spool file runner' do
    user.email = 'gregg.puhala@va.gov'
    render
    expect(rendered).to match(/Run Daily Spool File Job/)
  end
end
