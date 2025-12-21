class Consumption < ApplicationRecord
  belongs_to :user
  belongs_to :utility_type
  
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :reading_date, presence: true
  
  delegate :unit, to: :utility_type

  scope :by_utility_type, ->(utility_type_id) { where(utility_type_id: utility_type_id) if utility_type_id.present? }
  scope :from_date, ->(start_date) { where("reading_date >= ?", start_date) if start_date.present? }
  scope :to_date, ->(end_date) { where("reading_date <= ?", end_date) if end_date.present? }

  def self.monthly_summary_data(scope)
    scope.includes(:utility_type)
      .group_by { |c| [c.utility_type, c.reading_date.beginning_of_month] } # [[Electricity, 2025-01-01], [Electricity, 2025-02-01], [Gas, 2025-01-01]]
      .transform_values { |records| { sum: records.sum(&:value), count: records.count } } # { [Electricity, 2025-01-01] => {sum: 450.5, count: 3} }
  end

  def self.format_monthly_summary(monthly_data)
    result = {}

    # { 
    #   [Electricity, 2025-01-01] => {sum: 450.5, count: 3},
    #   [Electricity, 2025-02-01] => {sum: 420.0, count: 2},
    #   [Gas, 2025-01-01] => {sum: 100.0, count: 2}
    # }
    
    monthly_data.each do |(utility_type, month), stats|
      result[utility_type.name] ||= {
        utility_type_id: utility_type.id,
        unit: utility_type.unit,
        periods: []
      }
      
      result[utility_type.name][:periods] << {
        date: month.strftime('%Y-%m'),
        value: stats[:sum].round(2),
        count: stats[:count]
      }
    end
    
    result.each do |name, data|
      data[:periods].sort_by! { |p| p[:date] }
    end

    # {
    #   "Electricity" => {
    #     utility_type_id: 1,
    #     unit: "kWh",
    #     periods: [
    #       {date: "2025-01", value: 450.5, count: 3},
    #       {date: "2025-02", value: 420.0, count: 2}
    #     ]
    #   },
    #   "Gas" => {
    #     utility_type_id: 2,
    #     unit: "m³",
    #     periods: [{date: "2025-01", value: 100.0, count: 2}]
    #   }
    # }
    
    result
  end

  # Original versions: Uses data span for average calculation
  # params: start_date = Jan 1, end_date = Jan 31
  # dates = [Jan 5, Jan 15, Jan 25]
  # days = (Jan 25 - Jan 5) + 1 = 21 days
  # average_daily = 300 / 21 = 14.3 per day
  #
  def self.calculate_statistics(consumptions)
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
  def self.calculate_statistics_with_date_range(consumptions, start_date, end_date)
    stats = {}
    
    grouped = consumptions.group_by(&:utility_type)
    
    grouped.each do |utility_type, records|
      next if records.empty?
      
      values = records.map(&:value)
      
      if start_date.present? && end_date.present?
        days = (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
      else
        dates = records.map(&:reading_date).compact
        if dates.any?
          date_range = (dates.max - dates.min).to_i + 1
          days = date_range > 0 ? date_range : 1
        else
          days = 1
        end
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
end