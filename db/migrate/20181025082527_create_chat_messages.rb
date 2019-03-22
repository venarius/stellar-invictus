class CreateChatMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_messages do |t|
      t.references :user, foreign_key: true
      t.references :system, foreign_key: true
      t.integer :type
      t.text :body

      t.timestamps

      t.index [:user_id, :system_id, :type]
    end
  end
end
