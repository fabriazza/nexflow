class UtilityType < ApplicationRecord
  has_many :consumptions
  
  validates :name, presence: true, uniqueness: true
  validates :unit, presence: true
end