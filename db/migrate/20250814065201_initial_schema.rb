class InitialSchema < ActiveRecord::Migration[7.2]
  def change
    enable_extension 'plpgsql' unless extension_enabled?('plpgsql')

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :name
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :user_identities do |t|
      t.references :user, null: false, foreign_key: true # index 自動付与
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email
      t.string :display_name
      t.timestamps
    end
    add_index :user_identities, %i[provider uid], unique: true

    create_table :locations do |t|
      t.decimal :latitude,  precision: 9, scale: 6, null: false
      t.decimal :longitude, precision: 9, scale: 6, null: false
      t.timestamps
    end
    add_index :locations, %i[latitude longitude]
    add_check_constraint :locations,  '(latitude  BETWEEN -90  AND 90)',    name: 'chk_loc_lat'
    add_check_constraint :locations,  '(longitude BETWEEN -180 AND 180)',   name: 'chk_loc_lng'

    create_table :posts do |t|
      t.references :user,     null: false, foreign_key: true
      t.references :location, null: true,  foreign_key: true
      t.string  :title, null: false
      t.text    :body,  null: false
      t.datetime :event_datetime, null: false
      t.timestamps
    end
    add_index :posts, %i[user_id created_at]
    add_index :posts, :event_datetime

    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true # index 自動付与
      t.references :tag,  null: false, foreign_key: true # index 自動付与
      t.timestamps
    end
    add_index :post_tags, %i[post_id tag_id], unique: true

    create_table :weather_observations do |t|
      t.references :post, null: false, foreign_key: true, index: { unique: true }
      t.decimal :temperature_c, precision: 5, scale: 2
      t.integer :humidity_pct
      t.decimal :pressure_hpa, precision: 6, scale: 1
      t.datetime :observed_at
      t.jsonb :snapshot
      t.timestamps
    end
    add_index :weather_observations, :observed_at
    add_index :weather_observations, :snapshot, using: :gin
    add_check_constraint :weather_observations,
      '(temperature_c IS NULL OR (temperature_c BETWEEN -90 AND 60))', name: 'chk_wx_temp'
    add_check_constraint :weather_observations,
      '(humidity_pct  IS NULL OR (humidity_pct  BETWEEN 0   AND 100))', name: 'chk_wx_hum'
    add_check_constraint :weather_observations,
      '(pressure_hpa IS NULL OR (pressure_hpa BETWEEN 800 AND 1100))',  name: 'chk_wx_pres'
    add_check_constraint :weather_observations,
      '(snapshot IS NULL OR observed_at IS NOT NULL)',                  name: 'chk_wx_has_observed_at'
  end
end
