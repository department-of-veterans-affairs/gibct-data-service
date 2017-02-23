# frozen_string_literal: true
class DashboardsController < ApplicationController
  def index
    max_query = Upload.select('csv_type, MAX(updated_at) as max_updated_at').where(ok: true).group(:csv_type).to_sql

    @uploads = Upload.joins("INNER JOIN (#{max_query}) max_uploads ON uploads.csv_type = max_uploads.csv_type")
                     .where('uploads.updated_at = max_uploads.max_updated_at')
                     .paginate(page: params[:page]).order(:csv_type)
  end
end
