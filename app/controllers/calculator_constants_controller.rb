# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  include CollectionUpdatable

  def index
    if CalculatorConstant.versioning_enabled?
      previous_year = 1.year.ago.year

      @calculator_constants = CalculatorConstant.all
      @constants_unpublished = CalculatorConstant.unpublished?
      @previous_constants = CalculatorConstantVersionsArchive.circa(previous_year)
      @earliest_available_year = CalculatorConstantVersionsArchive.earliest_available_year
      @rate_adjustments = RateAdjustment.by_chapter_number
    else
      @calculator_constants = CalculatorConstant.all
    end
  end

  def update
    # Iterate over collection and update records if changes present
    updated = update_collection(&:name)

    unless updated.empty?
      flash[:success] = {
        updated_fields: updated
      }
    end

    # We want creating/updating a calculator constant to behave like uploading a spreadsheet.
    create_upload_row if CalculatorConstant.versioning_enabled?

    redirect_to action: :index
  end

  # Apply rate adjustments to associated constants
  def apply_rate_adjustments
    raise NotImplementedError, 'Versioning disabled' unless CalculatorConstant.versioning_enabled?

    updated = CalculatorConstant.where(rate_adjustment_id: rate_adjustment_id)
                                .map(&:apply_rate_adjustment)
    flash[:success] = {
      updated_fields: updated.pluck(:name)
    }

    # We want creating/updating a calculator constant to behave like uploading a spreadsheet.
    create_upload_row

    redirect_to action: :index
  end

  def export
    raise NotImplementedError, 'Versioning disabled' unless CalculatorConstant.versioning_enabled?

    start_year = params[:start_year].to_i
    end_year = params[:end_year].to_i
    export_name = "CalculatorConstants_#{start_year}_to_#{end_year}.csv"

    respond_to do |format|
      format.csv do
        send_data(CalculatorConstantVersionsArchive.export_version_history(start_year, end_year),
                  type: 'text/csv', filename: export_name)
      end
    end
  end

  private

  def rate_adjustment_id
    @rate_adjustment_id ||= params.require(:rate_adjustment_id)
  end

  # This causes the popup when generating a new version to include gonculator contstants as changed
  def create_upload_row
    Upload.create!(
      user: current_user,
      csv: 'Gonculator Constants Online',
      csv_type: 'CalculatorConstant',
      comment: 'Updated Gonculator Constant value(s)',
      ok: true,
      # This is how the uploads controller sets completed_at
      completed_at: Time.now.utc.to_fs(:db),
      multiple_file_upload: false
    )
  end
end
