class AddSystemToChatRooms < ActiveRecord::Migration[5.2]
  def change
    add_reference :chat_rooms, :system, foreign_key: true
  end
end
