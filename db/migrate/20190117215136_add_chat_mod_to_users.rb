class AddChatModToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :chat_mod, :boolean, default: false
  end
end
