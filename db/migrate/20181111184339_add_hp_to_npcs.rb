class AddHpToNpcs < ActiveRecord::Migration[5.2]
  def change
    add_column :npcs, :hp, :integer
  end
end
