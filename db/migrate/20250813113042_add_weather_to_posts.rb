class AddWeatherToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :weather_snapshot, :jsonb, null: true, default: nil
    add_column :posts, :temperature_c, :decimal, precision: 5, scale: 2, null: true
    add_column :posts, :humidity_pct, :integer, null: true
    add_column :posts, :pressure_hpa, :decimal, precision: 6, scale: 1, null: true
    add_column :posts, :weather_observed_at, :datetime, null: true
    add_index  :posts, :weather_observed_at
  end
end
