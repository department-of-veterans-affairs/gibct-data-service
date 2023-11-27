# frozen_string_literal: true

class AccreditationTypeKeywordsController < ApplicationController
  before_action :set_accreditation_type, only: %i[index new destroy]

  # GET /accreditation_type_keywords
  def index
    @accreditation_type_keywords =
      AccreditationTypeKeyword
      .where(accreditation_type: @accreditation_type)
      .order(:keyword_match)
  end

  # GET /accreditation_type_keywords/new
  def new
    @accreditation_type_keyword = AccreditationTypeKeyword.new
  end

  # POST /accreditation_type_keywords
  def create
    @accreditation_type_keyword = AccreditationTypeKeyword.new(accreditation_type_keyword_params)
    @accreditation_type = @accreditation_type_keyword.accreditation_type

    if @accreditation_type_keyword.valid?
      @accreditation_type_keyword.save
      respond_to do |format|
        format.html { redirect_to accreditation_type_keywords_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to accreditation_type_keywords_path }
        format.js { render action: 'new_with_errors' }
      end
    end
  end

  # DELETE /accreditation_type_keywords/1
  def destroy
    @accreditation_type_keyword = AccreditationTypeKeyword.find(params[:id])
    @accreditation_type = @accreditation_type_keyword.accreditation_type
    @accreditation_type_keyword.destroy
    respond_to do |format|
      format.html { redirect_to accreditation_type_keywords_path, notice: 'Keyword was successfully destroyed.' }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accreditation_type
    @accreditation_type = params[:accreditation_type]
  end

  # Only allow a list of trusted parameters through.
  def accreditation_type_keyword_params
    params.require(:accreditation_type_keyword).permit(:accreditation_type, :keyword_match)
  end
end
