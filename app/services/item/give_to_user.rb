class Item::GiveToUser < ApplicationService
  required :user, ensure: User
  required :loader
  required :amount

  optional :location

  def perform
    item = query.first_or_initialize
    item.count = 0 if item.new_record? # because count has a default of 1
    item.count += amount
    item.save
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
