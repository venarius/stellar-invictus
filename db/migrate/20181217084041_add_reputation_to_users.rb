class AddReputationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reputation_1, :float, default: 0.0
    add_column :users, :reputation_2, :float, default: 0.0
    add_column :users, :reputation_3, :float, default: 0.0
  end
end
