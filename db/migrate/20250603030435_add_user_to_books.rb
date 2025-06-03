class AddUserToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :user, foreign_key: true, null: true
  end
end
