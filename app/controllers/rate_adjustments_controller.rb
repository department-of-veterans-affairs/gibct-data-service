# frozen_string_literal: true

class RateAdjustmentsController < ApplicationController
  include CollectionUpdatable

  def update
    # Iterate over collection and update records if changes present
    update_collection
    @rate_adjustments = RateAdjustment.by_chapter_number

    respond_to do |format|
      format.turbo_stream { render template: 'calculator_constants/update' }
    end
  end
end
