# frozen_string_literal: true

class YellowRibbonDegreeLevelTranslationsController < ApplicationController
  def index
    @translation = YellowRibbonDegreeLevelTranslation.new
    @translations = YellowRibbonDegreeLevelTranslation.order(created_at: :desc)
  end

  def show
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/show_row',
                                                                locals: { translation: @translation })
      end
    end
  end

  def edit
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/edit_row',
                                                                locals: { translation: @translation })
      end
    end
  end

  def update
    @translation = YellowRibbonDegreeLevelTranslation.find(params[:id])

    respond_to do |format|
      if @translation.update(translation_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/show_row',
                                                                  locals: { translation: @translation })
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@translation, partial: 'yellow_ribbon_degree_level_translations/edit_row',
                                                                  locals: { translation: @translation })
        end
      end
    end
  end

  protected

  def translation_params
    params.require(:yellow_ribbon_degree_level_translation).permit(translations: [])
  end
end
