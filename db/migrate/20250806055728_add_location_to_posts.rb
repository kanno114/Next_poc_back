class AddLocationToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
  end
end
