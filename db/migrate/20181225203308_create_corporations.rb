class CreateCorporations < ActiveRecord::Migration[5.2]
  def change
    create_table :corporations do |t|
      t.string :name
      t.string :ticker
      t.text :bio
      t.text :motd
      t.float :tax, default: 0.0
      t.references :chat_room, foreign_key: true

      t.timestamps
    end
  end
end
