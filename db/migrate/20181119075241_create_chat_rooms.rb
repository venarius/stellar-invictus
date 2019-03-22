class CreateChatRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_rooms do |t|
      t.string :title
      t.references :location, foreign_key: true
      t.integer :chatroom_type

      t.timestamps
    end

    create_table :chat_rooms_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :chat_room, index: true
    end
  end
end
