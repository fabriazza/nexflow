class Consumption < ApplicationRecord
  belongs_to :user
  belongs_to :utility_type
  
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :reading_date, presence: true
  
  delegate :unit, to: :utility_type
end