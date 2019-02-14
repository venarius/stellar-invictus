class Item < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  belongs_to :spaceship, optional: true
  belongs_to :structure, optional: true
  belongs_to :mission, optional: true
  
  def get_attribute(attribute)
    atty = self.loader.split(".")
    out = ITEM_VARIABLES[atty[0]]
    self.loader.count('.').times do |i|
      out = out[atty[i+1]]
    end
    out[attribute]
  end
  
  def self.remove_from_user(attr)
    user = attr[:user]
    if attr[:location]
      item = Item.find_by(user: user, location: attr[:location], loader: attr[:loader], equipped: false) rescue nil
    else
      item = Item.find_by(spaceship: user.active_spaceship, loader: attr[:loader], equipped: false) rescue nil
    end
    
    if item
      item.update_columns(count: item.count - attr[:amount])
      item.destroy if item.reload.count <= 0
    end
  end
  
  def self.give_to_user(attr)
    user = attr[:user]
    if attr[:location]
      item = Item.find_by(user: user, location: attr[:location], loader: attr[:loader], equipped: false) rescue nil
      item ? item.update_columns(count: item.count + attr[:amount]) : Item.create(user: user, location: attr[:location], loader: attr[:loader], count: attr[:amount], equipped: false)
    else
      item = Item.find_by(spaceship: user.active_spaceship, loader: attr[:loader], equipped: false) rescue nil
      item ? item.update_columns(count: item.count + attr[:amount]) : Item.create(spaceship: user.active_spaceship, loader: attr[:loader], count: attr[:amount], equipped: false)
    end
  end
  
  def self.store_in_station(attr)
    user = attr[:user]
    item = Item.find_by(spaceship: user.active_spaceship, loader: attr[:loader], equipped: false) rescue nil
    if item
      if item.count > attr[:amount]
        item.update_columns(count: item.count - attr[:amount])
        Item.create(user: user, location: user.location, loader: attr[:loader], count: attr[:amount], equipped: false)
      else
        station_item = Item.find_by(user: user, location: user.location, loader: item.loader, equipped: false) rescue nil
        station_item ? (station_item.update_columns(count: station_item.count + item.count) and item.destroy) : item.update_columns(user_id: user.id, location_id: user.location.id, spaceship_id: nil, equipped: false, active: false)
      end
    end
  end
  
  def self.store_in_ship(attr)
    user = attr[:user]
    item = Item.find_by(user: user, location: user.location, loader: attr[:loader], equipped: false) rescue nil
    if item
      if item.count > attr[:amount]
        item.update_columns(count: item.count - attr[:amount])
        Item.create(spaceship: user.active_spaceship, loader: attr[:loader], count: attr[:amount], equipped: false)
      else
        ship_item = Item.find_by(spaceship: user.active_spaceship, loader: item.loader, equipped: false) rescue nil
        ship_item ? (ship_item.update_columns(count: ship_item.count + item.count) and item.destroy) : item.update_columns(user_id: nil, location_id: nil, spaceship_id: user.active_spaceship.id, equipped: false, active: false)
      end
    end
  end
end
