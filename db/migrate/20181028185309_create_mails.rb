class CreateMails < ActiveRecord::Migration[5.2]
  def change
    create_table :mails do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :header
      t.text :body
      t.integer :units
      
      t.index :sender_id
      t.index :recipient_id

      t.timestamps
    end
  end
end
