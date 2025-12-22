require 'rails_helper'

RSpec.describe Consumption, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', full_name: 'Test User') }
  let(:electricity) { UtilityType.create!(name: 'Electricity', unit: 'kWh') }
  let(:gas) { UtilityType.create!(name: 'Gas', unit: 'm³') }

  describe '#calculate_statistics' do
    it 'calculates statistics using actual data span (21 days between readings)' do
      consumptions = [
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 5)),
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 15)),
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 25))
      ]

      stats = Consumption.calculate_statistics(Consumption.where(id: consumptions.map(&:id)))

      expect(stats[electricity.id][:total]).to eq(300)
      expect(stats[electricity.id][:average_daily]).to be_within(0.1).of(300.0 / 21)
      expect(stats[electricity.id][:max_peak]).to eq(100)
    end

    it 'calculates statistics for multiple utility types' do
      consumptions = [
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 5)),
        user.consumptions.create!(utility_type: electricity, value: 150, reading_date: Date.new(2025, 1, 15)),
        user.consumptions.create!(utility_type: gas, value: 50, reading_date: Date.new(2025, 1, 10)),
        user.consumptions.create!(utility_type: gas, value: 75, reading_date: Date.new(2025, 1, 20))
      ]

      stats = Consumption.calculate_statistics(Consumption.where(id: consumptions.map(&:id)))

      expect(stats[electricity.id][:total]).to eq(250)
      expect(stats[electricity.id][:max_peak]).to eq(150)
      expect(stats[electricity.id][:average_daily]).to be_within(0.1).of(250.0 / 11)

      expect(stats[gas.id][:total]).to eq(125)
      expect(stats[gas.id][:max_peak]).to eq(75)
      expect(stats[gas.id][:average_daily]).to be_within(0.1).of(125.0 / 11)
    end

    it 'handles empty consumptions collection' do
      stats = Consumption.calculate_statistics(Consumption.none)

      expect(stats).to be_empty
    end

    it 'calculates correct max_peak value across different consumption values' do
      consumptions = [
        user.consumptions.create!(utility_type: electricity, value: 50, reading_date: Date.new(2025, 1, 5)),
        user.consumptions.create!(utility_type: electricity, value: 200, reading_date: Date.new(2025, 1, 15)),
        user.consumptions.create!(utility_type: electricity, value: 75, reading_date: Date.new(2025, 1, 25))
      ]

      stats = Consumption.calculate_statistics(Consumption.where(id: consumptions.map(&:id)))

      expect(stats[electricity.id][:total]).to eq(325)
      expect(stats[electricity.id][:max_peak]).to eq(200)
    end
  end

  describe '#calculate_statistics_date_range' do
    it 'calculates statistics using filter date range when params present (31 days)' do
      consumptions = [
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 5)),
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 15)),
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 25))
      ]

      stats = Consumption.calculate_statistics_with_date_range(
        Consumption.where(id: consumptions.map(&:id)),
        '2025-01-01',
        '2025-01-31'
      )

      expect(stats[electricity.id][:total]).to eq(300)
      expect(stats[electricity.id][:average_daily]).to be_within(0.1).of(300.0 / 31)
      expect(stats[electricity.id][:max_peak]).to eq(100)
    end

    it 'falls back to data span when no filter params provided' do
      consumptions = [
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 5)),
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 15)),
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 25))
      ]

      stats = Consumption.calculate_statistics_with_date_range(
        Consumption.where(id: consumptions.map(&:id)),
        nil,
        nil
      )

      expect(stats[electricity.id][:total]).to eq(300)
      expect(stats[electricity.id][:average_daily]).to be_within(0.1).of(300.0 / 21)
      expect(stats[electricity.id][:max_peak]).to eq(100)
    end

    it 'calculates statistics for multiple utility types with date range' do
      consumptions = [
        user.consumptions.create!(utility_type: electricity, value: 100, reading_date: Date.new(2025, 1, 5)),
        user.consumptions.create!(utility_type: electricity, value: 150, reading_date: Date.new(2025, 1, 15)),
        user.consumptions.create!(utility_type: gas, value: 50, reading_date: Date.new(2025, 1, 10)),
        user.consumptions.create!(utility_type: gas, value: 75, reading_date: Date.new(2025, 1, 20))
      ]

      stats = Consumption.calculate_statistics_with_date_range(
        Consumption.where(id: consumptions.map(&:id)),
        '2025-01-01',
        '2025-01-31'
      )

      expect(stats[electricity.id][:total]).to eq(250)
      expect(stats[electricity.id][:average_daily]).to be_within(0.1).of(250.0 / 31)

      expect(stats[gas.id][:total]).to eq(125)
      expect(stats[gas.id][:average_daily]).to be_within(0.1).of(125.0 / 31)
    end

    it 'handles empty consumptions collection' do
      stats = Consumption.calculate_statistics_with_date_range(
        Consumption.none,
        '2025-01-01',
        '2025-01-31'
      )

      expect(stats).to be_empty
    end
  end
end
