class System < ApplicationRecord
  has_many :users
  has_many :locations, dependent: :destroy
  
  enum security_status: [:high, :medium, :low]
  
  # Updates local players of every user in system
  def update_local_players
    users = User.where("online > 0").where(system: self)
    self.locations.each do |location|
      ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
        count: users.count, names: ApplicationController.helpers.map_and_sort(users))
    end
  end
end
