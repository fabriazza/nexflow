class AddIndexToConsumptionsReadingDate < ActiveRecord::Migration[8.1]
  def change
    add_index :consumptions, :reading_date
  end
end
