# frozen_string_literal: true

class CostOfLivingAdjustmentsController < ApplicationController
  include CollectionUpdatable

  def update
    update_collection
  end
end
