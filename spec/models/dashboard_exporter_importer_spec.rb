# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardExporterImporter, type: :model do
  describe '#initialize' do
    before do
      create(:user)
      # rubocop:disable Rspec/AnyInstance
      allow_any_instance_of(described_class).to receive(:login_to_dashboard).and_return(true)
      # rubocop:enable Rspec/AnyInstance
    end

    it 'sets the user, password, and url instance variables' do
      user = User.first

      dei = described_class.new(user.email, user.password, 'l')

      expect(dei.user).to eq user.email
      expect(dei.pass).to eql user.password

      expect(dei.login_url).to eq DashboardExporterImporter::LOCAL_URL
      expect(dei.dashboard_url).to eq DashboardExporterImporter::LOCAL_DASHBOARD
      expect(dei.import_prefix).to eq DashboardExporterImporter::LOCAL_IMPORT_PREFIX
    end
  end
end
