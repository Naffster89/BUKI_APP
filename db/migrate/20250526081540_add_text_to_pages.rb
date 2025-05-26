class AddTextToPages < ActiveRecord::Migration[7.1]
  def change
    remove_column :pages, :text, :text
    add_column :pages, :text, :jsonb
  end
end
