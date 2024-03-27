# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboards/accreditation_issues', type: :view do
  before do # set the instance variables from the controller before the view is rendered or tests fail
    create(:version, :production)
    create(:institution, :accreditation_issue)
    create(:institution, :with_accreditation)
    create(:accreditation_institute_campus)
    create(:accreditation_record)

    # rubocop:disable Rails/SkipsModelValidations
    Institution.update_all(version_id: Version.production.first.id)
    # rubocop:enable Rails/SkipsModelValidations

    @production_versions = Version.production.newest.includes(:user).limit(1)
    @unaccrediteds = Institution.unaccrediteds
  end

  it 'shows the table header for institutions with potential accreditation issues' do
    render
    expect(rendered).to match(/Institution Name/)
    expect(rendered).to match(/Facility Code/)
    expect(rendered).to match(/OPE/)
    expect(rendered).to match(/Agency Name/)
    expect(rendered).to match(/AR End Date/)
    expect(rendered).to match(/Reasons for inclusion on this report/)
  end

  it 'shows institutions with potential accreditation issues' do
    render
    expect(rendered).to match(/ACME INC/)
  end

  it 'does not show accredited institutions' do
    render
    expect(rendered).not_to match(/University of Toledo/)
  end
end
