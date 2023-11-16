# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.where(version: Version.current_production) }
  let(:factory_class) { InstitutionBuilder::Factory }

  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
    allow(VetsApi::Service).to receive(:feature_enabled?).and_return(false)
    create(:version, :production)
  end

  describe '#run' do
    before do
      create :weam, :institution_builder
      create :crosswalk, :institution_builder
    end

    context 'when successful' do
      it 'generates a new production version' do
        create :version
        old_version = Version.current_production
        described_class.run(user)
        version = Version.current_production
        expect(version).not_to eq(old_version)
        expect(version.production).to be_truthy
        expect(version).not_to be_generating
      end

      it "writes '#{CommonInstitutionBuilder::VersionGeneration::PUBLISH_COMPLETE_TEXT}' to the log" do
        allow(Rails.logger).to receive(:info)
        described_class.run(user)
        expect(Rails.logger).to have_received(:info).with(/Version\sgenerated\sand\spublished/).at_least(:once)
      end

      it 'does not write "error" to the log' do
        allow(Rails.logger).to receive(:error)
        described_class.run(user)
        expect(Rails.logger).to have_received(:error).with(/error/).exactly(0).times
      end
    end

    context 'when not successful' do
      it 'logs errors at the database level' do
        error_message = 'There was an error occurring at the database level: BOOM!'
        statement_invalid = ActiveRecord::StatementInvalid.new('BOOM!')
        statement_invalid.set_backtrace(%(backtrace))
        allow(factory_class).to receive(:add_crosswalk).and_raise(statement_invalid)
        allow(Rails.logger).to receive(:error).with(error_message)
        described_class.run(user)
        expect(Rails.logger).to have_received(:error).with(error_message)
      end

      it 'logs errors at the Rails level' do
        error_message = 'There was an error of unexpected origin: BOOM!'
        allow(factory_class).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        allow(Rails.logger).to receive(:error).with(error_message)
        described_class.run(user)
        expect(Rails.logger).to have_received(:error).with(error_message)
      end

      it 'does not change the institutions or versions if not successful' do
        allow(factory_class).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        create :version
        version = Version.current_production
        described_class.run(user)
        expect(Institution.count).to be_zero
        expect(Version.current_production).to eq(version)
      end
    end
  end
end
