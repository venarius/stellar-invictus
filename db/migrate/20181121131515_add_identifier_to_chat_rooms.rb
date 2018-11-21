class AddIdentifierToChatRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_rooms, :identifier, :string
  end
end
