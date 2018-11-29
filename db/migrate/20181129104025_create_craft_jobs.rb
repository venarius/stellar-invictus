class CreateCraftJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :craft_jobs do |t|
      t.datetime :completion
      t.string :loader
      t.references :user, foreign_key: true
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end
