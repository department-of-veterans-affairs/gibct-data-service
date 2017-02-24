# frozen_string_literal: true
class DashboardsController < ApplicationController
  def index
    @uploads = Upload.last_uploads
  end

  def build
    @version = InstitutionBuilder.run(current_user)
  end
end
