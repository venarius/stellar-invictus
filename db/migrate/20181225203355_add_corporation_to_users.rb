class AddCorporationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :corporation, foreign_key: true
    add_column :users, :corporation_role, :integer, default: 0
  end
end
