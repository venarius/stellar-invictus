class CreateMissions < ActiveRecord::Migration[5.2]
  def change
    create_table :missions do |t|
      t.integer :mission_type
      t.integer :mission_status
      t.string :agent_name
      t.string :agent_avatar
      t.integer :text
      t.integer :reward
      t.integer :deliver_to
      t.integer :mission_location_id
      t.references :faction, foreign_key: true
      t.references :user, foreign_key: true
      t.references :location, foreign_key: true
      t.integer :difficulty
      t.integer :enemy_amount
      t.string :mission_loader
      t.integer :mission_amount
      t.float :faction_bonus
      t.float :faction_malus

      t.timestamps
    end
  end
end
