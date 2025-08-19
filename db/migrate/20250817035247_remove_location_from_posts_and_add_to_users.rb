class RemoveLocationFromPostsAndAddToUsers < ActiveRecord::Migration[7.2]
  def change
    # postsテーブルからlocation_idを削除
    remove_reference :posts, :location, foreign_key: true, index: true

    # usersテーブルにlocation_idを追加
    add_reference :locations, :user, foreign_key: true, index: true
  end
end