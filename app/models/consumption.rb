class Consumption < ApplicationRecord
  belongs_to :user
  belongs_to :utility_type
  
  validates :value, presence: true, numericality: { greater_than: 0 }
  
  delegate :unit, to: :utility_type
end