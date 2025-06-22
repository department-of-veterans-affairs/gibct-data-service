# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    updated_fields = []
    submitted_constants = params['calculator_constants']
    update_calculator_constant(submitted_constants, updated_fields)
    unless updated_fields.empty?
      flash[:success] = {
        updated_fields: updated_fields
      }
    end

    # We want creating/updating a calculator constant to behave like uploading a spreadsheet.
    create_upload_row

    redirect_to action: :index
  end

  private

  def update_calculator_constant(submitted_constants, updated_fields)
    constant_fields = CalculatorConstant.where(name: submitted_constants.keys)
    constant_fields.each do |constant|
      submitted_value = submitted_constants[constant.name]
      if submitted_value.to_d != constant.float_value.to_d
        constant.update(float_value: submitted_value)
        updated_fields.push(constant.name)
      end
    end
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
