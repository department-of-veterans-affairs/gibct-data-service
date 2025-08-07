# frozen_string_literal: true

class YellowRibbonDegreeLevelTranslationsController < ApplicationController
  def index
    @translation = YellowRibbonDegreeLevelTranslation.new
    load_models
  end

  def create
    @translation = YellowRibbonDegreeLevelTranslation.new(translation_params)

    if @translation.save
      redirect_to yellow_ribbon_degree_level_translations_path, notice: "Entry Created"
    else
      load_models
      render :index, status: :unprocessable_entity
    end
  end
  
  def show
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/show_row', locals: { translation: @translation }) }
    end
  end
  
  def edit
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/edit_row', locals: { translation: @translation }) }
    end
  end

  def update
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])

    respond_to do |format|
      if @translation.update(translation_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/show_row', locals: { translation: @translation }) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/edit_row', locals: { translation: @translation }) }
      end
    end
  end

  def destroy
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])
    @translation.destroy
    redirect_to yellow_ribbon_degree_level_translations_path, notice: "Entry Deleted"
  end

  protected

  def translation_params
    params.require(:yellow_ribbon_degree_level_translation).permit(:raw_degree_level, :translated_degree_level)
  end

  def load_models
    @yellow_ribbon_degree_level_translations = YellowRibbonDegreeLevelTranslation.order(raw_degree_level: :asc)
    @unmatched_programs = YellowRibbonProgram.includes(:institution).version(Version.current_production).joins('left join yellow_ribbon_degree_level_translations on lower(degree_level) = raw_degree_level').where(yellow_ribbon_degree_level_translations: {id: nil}).distinct
  end
end
