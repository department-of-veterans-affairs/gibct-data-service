class MousController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_mou, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @mous = Mou.paginate(page: params[:page])
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
    @mou = Mou.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @mou = Mou.create(mou_params)

    respond_to do |format|
      if @mou.persisted?
        format.html { redirect_to @mou, notice: "#{@mou.institution} created." }
      else
        label = 'Errors mou this file from being saved:'
        errors = @mou.errors.full_messages
        flash.alert = MousController.pretty_error(label, errors).html_safe

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
    rc = @mou.update(mou_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @mou, notice: "#{@mou.institution} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @mou.errors.full_messages
        flash.alert = MousController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @mou.destroy

    respond_to do |format|
      format.html do
        redirect_to mous_url,
                    notice: "#{@mou.institution} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_mou
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_mou
    @mou = Mou.find(params[:id])
  end

  #############################################################################
  ## mou_params
  ## Strong parameters
  #############################################################################
  def mou_params
    params.require(:mou).permit(
      :institution, :ope, :dodmou
    )
  end
end
