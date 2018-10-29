class RenameMailsToGameMail < ActiveRecord::Migration[5.2]
  def change
    rename_table :mails, :game_mails
  end
end
