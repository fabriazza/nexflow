class ConsumptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_consumption, only: [:show, :edit, :update, :destroy]
  before_action :set_utility_types, only: [:index, :new, :edit, :create, :update]

  def index
    @consumptions = current_user.consumptions.includes(:utility_type)
    @consumptions = @consumptions.by_utility_type(params[:utility_type_id])
                                 .from_date(params[:start_date])
                                 .to_date(params[:end_date])
                                 .order(reading_date: :desc, created_at: :desc)
    @statistics = Consumption.calculate_statistics(@consumptions)
  end

  def show
  end

  def new
    @consumption = current_user.consumptions.build
  end

  def create
    @consumption = current_user.consumptions.build(consumption_params)
    
    if @consumption.save
      redirect_to @consumption, notice: 'Consumption was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @consumption.update(consumption_params)
      redirect_to @consumption, notice: 'Consumption was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @consumption.destroy
    redirect_to consumptions_url, notice: 'Consumption was successfully deleted.'
  end

  def monthly_summary
    consumptions = current_user.consumptions
    monthly_data = Consumption.monthly_summary_data(consumptions)
    
    render json: Consumption.format_monthly_summary(monthly_data)
  end

  private

  def set_consumption
    @consumption = current_user.consumptions.find(params[:id])
  end

  def set_utility_types
    @utility_types = UtilityType.all
  end

  def consumption_params
    params.require(:consumption).permit(:utility_type_id, :value, :reading_date)
  end

end
