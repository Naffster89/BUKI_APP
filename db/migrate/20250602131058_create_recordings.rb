class CreateRecordings < ActiveRecord::Migration[7.1]
  def change
    create_table :recordings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :page, null: false, foreign_key: true
      t.string :language

      t.timestamps
    end
  end
end
