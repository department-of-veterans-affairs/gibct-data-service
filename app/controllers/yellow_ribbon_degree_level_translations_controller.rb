# frozen_string_literal: true

class YellowRibbonDegreeLevelTranslationsController < ApplicationController
  def index
    @translation = YellowRibbonDegreeLevelTranslation.new
    @yellow_ribbon_degree_level_translations = YellowRibbonDegreeLevelTranslation.order(raw_degree_level: :asc)
  end

  def create
    @translation = YellowRibbonDegreeLevelTranslation.new(translation_params)

    if @translation.save
      redirect_to yellow_ribbon_degree_level_translations_path, notice: "Entry Created"
    else
      @yellow_ribbon_degree_level_translations = YellowRibbonDegreeLevelTranslation.order(raw_degree_level: :asc)
      render :index, status: :unprocessable_entity
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
end
