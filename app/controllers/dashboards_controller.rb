# frozen_string_literal: true
class DashboardsController < ApplicationController
  def index
    @uploads = Upload.last_uploads
  end
end
