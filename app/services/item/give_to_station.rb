class Item::GiveToStation < ApplicationService
  required :user, ensure: User
  required :loader
  required :amount

  def perform
    item = Item.where(spaceship: user.active_spaceship, loader: loader, equipped: false).first
    if item
      if item.count > amount
        Item.transaction do
          item.decrement!(:count, amount)
          Item::GiveToUser.(user: user, loader: loader, location: user.location, amount: amount)
        end
      else
        station_item = Item.where(user: user, location: user.location, loader: item.loader, equipped: false).first
        if station_item
          Item.transaction do
            station_item.increment!(:count, item.count)
            item.destroy
          end
        else
          item.update(
            user: user,
            location: user.location,
            spaceship_id: nil,
            active: false
          )
        end
      end
    end
  end
end
