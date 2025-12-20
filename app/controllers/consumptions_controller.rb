class ConsumptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_consumption, only: [:show, :edit, :update, :destroy]

  def index
    @consumptions = current_user.consumptions.includes(:utility_type)
    @consumptions = apply_filters(@consumptions)
    @consumptions = @consumptions.order(reading_date: :desc, created_at: :desc)
    @utility_types = UtilityType.all
    @statistics = calculate_statistics(@consumptions)
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

  # Original versions: Uses data span for average calculation
  # params: start_date = Jan 1, end_date = Jan 31
  # dates = [Jan 5, Jan 15, Jan 25]
  # days = (Jan 25 - Jan 5) + 1 = 21 days
  # average_daily = 300 / 21 = 14.3 per day
  def calculate_statistics(consumptions)
    stats = {}
    
    grouped = consumptions.group_by(&:utility_type)
    
    grouped.each do |utility_type, records|
      next if records.empty?
      
      values = records.map(&:value)
      dates = records.map(&:reading_date).compact
      
      if dates.any?
        date_range = (dates.max - dates.min).to_i + 1
        days = date_range > 0 ? date_range : 1
      else
        days = 1
      end
      
      stats[utility_type.id] = {
        utility_type: utility_type,
        total: values.sum,
        average_daily: values.sum / days.to_f,
        max_peak: values.max
      }
    end
    
    stats
  end

  # Alternative version: Uses filter date range instead of data date range for average calculation
  # params: start_date = Jan 1, end_date = Jan 31
  # dates = [Jan 5, Jan 15, Jan 25]
  # days = (Jan 31 - Jan 1) + 1 = 31 days
  # average_daily = 300 / 31 = 9.7 per day
  #
  # def calculate_statistics(consumptions)
  #   stats = {}
  #   
  #   grouped = consumptions.group_by(&:utility_type)
  #   
  #   grouped.each do |utility_type, records|
  #     next if records.empty?
  #     
  #     values = records.map(&:value)
  #     
  #     if params[:start_date].present? && params[:end_date].present?
  #       days = (Date.parse(params[:end_date]) - Date.parse(params[:start_date])).to_i + 1
  #     else
  #       dates = records.map(&:reading_date).compact
  #       if dates.any?
  #         date_range = (dates.max - dates.min).to_i + 1
  #         days = date_range > 0 ? date_range : 1
  #       else
  #         days = 1
  #       end
  #     end
  #     
  #     stats[utility_type.id] = {
  #       utility_type: utility_type,
  #       total: values.sum,
  #       average_daily: values.sum / days.to_f,
  #       max_peak: values.max
  #     }
  #   end
  #   
  #   stats
  # end
end
