# frozen_string_literal: true

RSpec.shared_context('with setup') do
  let(:user) { User.first }
  let(:institutions) { Institution.where(version: Version.current_production) }
  let(:factory_class) { InstitutionBuilder::Factory }

  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
    allow(VetsApi::Service).to receive(:feature_enabled?).and_return(false)
    create(:version, :production)
  end
end
