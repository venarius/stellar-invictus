class RemoveLocationFromChatMessages < ActiveRecord::Migration[5.2]
  def change
    remove_reference :chat_messages, :system, foreign_key: true
    remove_columns :chat_messages, :type

    add_reference :chat_messages, :chat_room, foreign_key: true
  end
end
