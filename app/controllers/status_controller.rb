# frozen_string_literal: true
class StatusController < ApplicationController
  skip_before_action :authenticate_user!

  def status
    app_status = { "status": 'ok' }
    render json: app_status
  end
end
