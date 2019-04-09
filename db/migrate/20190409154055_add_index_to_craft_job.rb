class AddIndexToCraftJob < ActiveRecord::Migration[5.2]
  def change
    rename_column :craft_jobs, :completion, :completed_at
    add_index :craft_jobs, :completed_at
  end
end
