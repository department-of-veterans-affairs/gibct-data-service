# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/utilities/caution_flag_templates/caution_flag_template'
require_relative '../../app/utilities/caution_flag_templates/accreditation_caution_flag'
require_relative '../../app/utilities/caution_flag_templates/hcm_caution_flag'
require_relative '../../app/utilities/caution_flag_templates/sec702_caution_flag'
require_relative '../../app/utilities/caution_flag_templates/mou_caution_flag'

RSpec.describe CautionFlag, type: :model do
  describe 'when validating' do
    subject(:caution_flag) { build :caution_flag, version_id: version.id }

    let(:version) { build :version, :preview }

    it 'has a valid factory' do
      expect(caution_flag).to be_valid
    end
  end

  describe 'when using scope distinct_flags' do
    it 'has distinct caution flags' do
      create_list :caution_flag, 3, :accreditation_issue

      expect(described_class.distinct_flags.to_a.size).to eq(1)
    end
  end

  describe '#build' do
    let(:version) { create :version, :production }
    let(:institution) { create :institution, version_id: version.id }

    # can't check equals on several fields because of quotes being escaped for inserting
    # into SQL
    CautionFlagTemplate.descendants.each do |template|
      context "creates flag with #{template.name} values" do
        before do
          clause_sql = <<-SQL
          FROM institutions
          WHERE id = #{institution.id}
          SQL

          described_class.build(version.id, template, clause_sql)
        end

        it "has #{template.name} NAME value" do
          flag = described_class.where(source: template::NAME,
                                       version_id: version.id,
                                       institution_id: institution.id).first
          expect(flag.source).to eq(template::NAME)
        end

        it "has #{template.name} TITLE value" do
          flag = described_class.where(source: template::NAME,
                                       version_id: version.id,
                                       institution_id: institution.id).first
          expect(flag.title).to be_present
        end

        it "has #{template.name} DESCRIPTION value" do
          flag = described_class.where(source: template::NAME,
                                       version_id: version.id,
                                       institution_id: institution.id).first
          expect(flag.description).to be_present
        end

        it "has #{template.name} LINK_TEXT value" do
          flag = described_class.where(source: template::NAME,
                                       version_id: version.id,
                                       institution_id: institution.id).first
          expect(flag.link_text).to be_present
        end

        it "has #{template.name} LINK_URL value" do
          flag = described_class.where(source: template::NAME,
                                       version_id: version.id,
                                       institution_id: institution.id).first
          expect(flag.link_url).to eq(template::LINK_URL)
        end
      end
    end
  end
end
