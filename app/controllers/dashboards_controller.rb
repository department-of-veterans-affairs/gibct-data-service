# frozen_string_literal: true
class DashboardsController < ApplicationController
  include Alertable

  def index
    @production_version = Version.production_version
    @preview_version = Version.preview_version
  end
end
