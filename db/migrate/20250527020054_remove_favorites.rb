class RemoveFavorites < ActiveRecord::Migration[7.1]
  def change
    drop_table :favorites
  end
end
