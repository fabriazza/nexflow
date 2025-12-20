class ConsumptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_consumption, only: [:show, :edit, :update, :destroy]

  def index
    @consumptions = current_user.consumptions.includes(:utility_type)
    @consumptions = apply_filters(@consumptions)
    @consumptions = @consumptions.order(reading_date: :desc, created_at: :desc)
    @utility_types = UtilityType.all
  end

  def show
  end

  def new
    @consumption = current_user.consumptions.build
    @utility_types = UtilityType.all
  end

  def create
    @consumption = current_user.consumptions.build(consumption_params)
    
    if @consumption.save
      redirect_to @consumption, notice: 'Consumption was successfully created.'
    else
      @utility_types = UtilityType.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @utility_types = UtilityType.all
  end

  def update
    if @consumption.update(consumption_params)
      redirect_to @consumption, notice: 'Consumption was successfully updated.'
    else
      @utility_types = UtilityType.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @consumption.destroy
    redirect_to consumptions_url, notice: 'Consumption was successfully deleted.'
  end

  private

  def set_consumption
    @consumption = current_user.consumptions.find(params[:id])
  end

  def consumption_params
    params.require(:consumption).permit(:utility_type_id, :value, :reading_date)
  end

  def apply_filters(scope)
    if params[:utility_type_id].present?
      scope = scope.where(utility_type_id: params[:utility_type_id])
    end

    if params[:start_date].present?
      scope = scope.where("reading_date >= ?", params[:start_date])
    end

    if params[:end_date].present?
      scope = scope.where("reading_date <= ?", params[:end_date])
    end

    scope
  end
end
