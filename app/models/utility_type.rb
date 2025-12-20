class UtilityType < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  
end