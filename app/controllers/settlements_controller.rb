class SettlementsController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_settlement, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @settlements = Settlement.paginate(page: params[:page])
  end

  #############################################################################
  ## show
  #############################################################################
  def show
    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## new
  #############################################################################
  def new
    @settlement = Settlement.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @settlement = Settlement.create(settlement_params)

    respond_to do |format|
      if @settlement.persisted?
        format.html { redirect_to @settlement, notice: "#{@settlement.institution} created." }
      else
        label = 'Errors settlement this file from being saved:'
        errors = @settlement.errors.full_messages
        flash.alert = SettlementsController.pretty_error(label, errors).html_safe

        format.html { render :new }
      end
    end
  end

  #############################################################################
  ## edit
  #############################################################################
  def edit
    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## update
  #############################################################################
  def update
    rc = @settlement.update(settlement_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @settlement, notice: "#{@settlement.institution} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @settlement.errors.full_messages
        flash.alert = SettlementsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @settlement.destroy

    respond_to do |format|
      format.html do
        redirect_to settlements_url,
                    notice: "#{@settlement.institution} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_settlement
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_settlement
    @settlement = Settlement.find(params[:id])
  end

  #############################################################################
  ## settlement_params
  ## Strong parameters
  #############################################################################
  def settlement_params
    params.require(:settlement).permit(
      :institution, :cross, :settlement_description
    )
  end
end
