class AddUniqueIndexes < ActiveRecord::Migration[5.2]
  def change
    # If you use a `uniqueness` validation, you should have a unique index on that attribute
    add_index :users, [:family_name, :name], unique: true

    add_index :corporations, :ticker, unique: true
    add_index :corporations, :name, unique: true
  end
end
