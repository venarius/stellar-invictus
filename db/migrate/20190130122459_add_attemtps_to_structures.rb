class AddAttemtpsToStructures < ActiveRecord::Migration[5.2]
  def change
    add_column :structures, :attempts, :integer, default: 0
  end
end
