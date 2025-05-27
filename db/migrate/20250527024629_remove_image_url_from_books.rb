class RemoveImageUrlFromBooks < ActiveRecord::Migration[7.1]
  def change
    remove_column :books, :image_url, :string
  end
end
