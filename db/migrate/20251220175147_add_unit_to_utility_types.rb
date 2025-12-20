class AddUnitToUtilityTypes < ActiveRecord::Migration[8.1]
  def change
    add_column :utility_types, :unit, :string
  end
end
