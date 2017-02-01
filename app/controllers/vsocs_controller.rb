class VsocsController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_vsoc, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @vsocs = Vsoc.paginate(page: params[:page])
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
    @vsoc = Vsoc.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @vsoc = Vsoc.create(vsoc_params)

    respond_to do |format|
      if @vsoc.persisted?
        format.html { redirect_to @vsoc, notice: "#{@vsoc.institution} created." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @vsoc.errors.full_messages
        flash.alert = VsocsController.pretty_error(label, errors).html_safe

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
    rc = @vsoc.update(vsoc_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @vsoc, notice: "#{@vsoc.institution} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @vsoc.errors.full_messages
        flash.alert = VsocsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @vsoc.destroy

    respond_to do |format|
      format.html do
        redirect_to vsocs_url,
                    notice: "#{@vsoc.institution} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_vsoc
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_vsoc
    @vsoc = Vsoc.find(params[:id])
  end

  #############################################################################
  ## vsoc_params
  ## Strong parameters
  #############################################################################
  def vsoc_params
    params.require(:vsoc).permit(
      :facility_code, :institution, :vetsuccess_name, :vetsuccess_email
    )
  end
end
