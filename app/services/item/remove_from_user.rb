class Item::RemoveFromUser < ApplicationService
  required :user, ensure: User
  required :loader
  required :amount

  optional :location
  optional :spaceship

  def perform
    if (item = query.first)
      item.count -= amount
      item.count.positive? ? item.save : item.destroy
    else
      fail!("Item(#{item_id}) not found")
    end
  end

  private

  def query
    result = Item.where(loader: loader, equipped: false)
    if location.present?
      result = result.where(user: user, location: location)
    else
      result = result.where(spaceship: user.active_spaceship)
    end
    result
  end
end
