# frozen_string_literal: true

class RulesController < ApplicationController
  def index
    @caution_flag_rules = CautionFlagRule.all
  end

  def update
    binding.pry
    updated_fields = []
    submitted_constants = params['rules']
    update_rules(submitted_constants, updated_fields)
    unless updated_fields.empty?
      flash[:success] = {
          updated_fields: updated_fields
      }
    end
    redirect_to action: :index
  end

  private
  def update_rules(x,y)
    puts x
    puts y
  end
end
