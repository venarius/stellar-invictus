class AddFactionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :faction, foreign_key: true
  end
end
