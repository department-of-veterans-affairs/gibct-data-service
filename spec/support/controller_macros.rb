# frozen_string_literal: true

module ControllerMacros
  def login_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      user = FactoryBot.create(:user)
      sign_in user
    end
  end

  def logout_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      user = FactoryBot.create(:user)
      sign_in user
      sign_out user
    end
  end

  def load_table(klass, options)
    csv_name = "#{klass.name.underscore}.csv"
    csv_type = klass.name
    csv_path = 'spec/fixtures'

    upload = create :upload, csv_type: csv_type, csv_name: csv_name, user: User.first
    klass.load("#{csv_path}/#{csv_name}", options)
    upload.update(ok: true)
  end
end
