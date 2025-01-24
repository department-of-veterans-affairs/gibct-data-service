# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboards/index', type: :view do
  before do # set the instance variables from the controller before the view is rendered or tests fail
    create(:version, :production)
    create(:version, :preview)
    @production_versions = Version.production.newest.includes(:user).limit(1)
    @preview_versions = Version.preview.newest.includes(:user).limit(1)
    @latest_uploads = Upload.since_last_version
  end

  it 'shows a title for institutions with potential accreditation issues' do
    render
    expect(rendered).to match(/Institutions With No Accreditation/)
  end

  it 'does not show the enable locked fetches button if there are no failed fetches' do
    create(:upload, :valid_upload)
    render
    expect(rendered).not_to match(/Enable locked Fetches/)
  end

  it 'shows the enable locked fetches button if there are failed fetches' do
    create(:upload, :failed_upload)
    render
    expect(rendered).to match(/Enable locked Fetches/)
  end

  # The default scenario actually has generation in progress but it is newer than 10 minutes
  it 'does not show the unlock button if generation is in progress but newer than 10 minutes' do
    render
    expect(rendered).not_to match(/Unlock/)
  end

  it 'does not show the unlock button if not generating a version' do
    Version.where(production: false).delete_all
    render
    expect(rendered).not_to match(/Unlock/)
  end

  it 'does show the unlock button if generation is in progress and older than 10 minutes' do
    Version.where(production: false).update(created_at: Time.now.utc - 11.minutes)
    render
    expect(rendered).to match(/Unlock/)
  end
end
