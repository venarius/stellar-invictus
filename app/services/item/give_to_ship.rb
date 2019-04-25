class Item::GiveToShip < ApplicationService
  required :user, ensure: User
  required :loader
  required :amount

  def perform
    item = Item.where(user: user, location: user.location, loader: loader, equipped: false).first
    fail!("Item(#{loader}) not found") unless item

    if item.count > amount
      # If they have enough,
      Item.transaction do
        item.decrement!(:count, amount)
        Item::GiveToUser.(user: user, loader: loader, amount: amount)
      end
    else
      ship_item = Item.where(
          spaceship: user.active_spaceship,
          loader: loader,
          equipped: false
        ).first
      if ship_item
        ship_item.increment!(:count, item.count)
        item.destroy
      else
        # move item to ship
        item.update(
          user_id: nil,
          location_id: nil,
          spaceship: user.active_spaceship,
          active: false
        )
      end
    end
  end
end
