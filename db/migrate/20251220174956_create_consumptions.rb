class CreateConsumptions < ActiveRecord::Migration[8.1]
  def change
    create_table :consumptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :utility_type, null: false, foreign_key: true
      t.decimal :value, precision: 10, scale: 2
      t.date :reading_date

      t.timestamps
    end
  end
end
