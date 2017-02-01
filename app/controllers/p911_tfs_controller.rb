class P911TfsController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_p911_tf, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @p911_tfs = P911Tf.paginate(page: params[:page])
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
    @p911_tf = P911Tf.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @p911_tf = P911Tf.create(p911_tf_params)

    respond_to do |format|
      if @p911_tf.persisted?
        format.html { redirect_to @p911_tf, notice: "#{@p911_tf.institution} created." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @p911_tf.errors.full_messages
        flash.alert = P911TfsController.pretty_error(label, errors).html_safe

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
    rc = @p911_tf.update(p911_tf_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @p911_tf, notice: "#{@p911_tf.institution} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @p911_tf.errors.full_messages
        flash.alert = P911TfsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @p911_tf.destroy

    respond_to do |format|
      format.html do
        redirect_to p911_tfs_url,
                    notice: "#{@p911_tf.institution} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_p911_tf
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_p911_tf
    @p911_tf = P911Tf.find(params[:id])
  end

  #############################################################################
  ## p911_tf_params
  ## Strong parameters
  #############################################################################
  def p911_tf_params
    params.require(:p911_tf).permit(
      :facility_code, :institution, :p911_tuition_fees, :p911_recipients
    )
  end
end
