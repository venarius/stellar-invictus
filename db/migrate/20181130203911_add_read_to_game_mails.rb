class AddReadToGameMails < ActiveRecord::Migration[5.2]
  def change
    add_column :game_mails, :read, :boolean, default: false
  end
end
