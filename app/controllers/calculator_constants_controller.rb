# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  include CollectionUpdatable

  before_action :set_rate_adjustment_id, only: :apply_rate_adjustments

  def index
    @calculator_constants = CalculatorConstant.all
    @rate_adjustments = RateAdjustment.by_chapter_number
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
    create_upload_row

    redirect_to action: :index
  end

  # Apply rate adjustments to associated constants
  def apply_rate_adjustments
    updated = CalculatorConstant.where(rate_adjustment_id: @rate_adjustment_id)
                                .find_each(&:apply_rate_adjustment)
    flash[:success] = {
      updated_fields: updated.pluck(:name)
    }
    redirect_to action: :index
  end

  private

  def set_rate_adjustment_id
    @rate_adjustment_id = params.require(:rate_adjustment_id)
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
