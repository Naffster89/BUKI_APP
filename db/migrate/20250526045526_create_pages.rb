class CreatePages < ActiveRecord::Migration[7.1]
  def change
    create_table :pages do |t|
      t.references :book, null: false, foreign_key: true
      t.text :text
      t.integer :page_number

      t.timestamps
    end
  end
end
