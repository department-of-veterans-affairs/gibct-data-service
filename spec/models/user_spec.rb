require "rails_helper"

RSpec.describe User, type: :model do
  describe "When creating" do
    it "factory is valid" do
      expect(create(:user)).to be_valid
    end

    it "needs an email" do
      expect { create(:user, :no_email) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "needs a proper email" do
      expect { create :user, :bad_email }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "needs a va.gov email" do
      expect { create :user, :bad_email_domain }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "needs a password" do
      expect { create :user, :no_password }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "needs a password >= 8 characters" do
      expect { create :user, :short_password }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "needs a password <= 72 characters" do
      expect { create :user, :long_password }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
