class EquipmentController < ApplicationController

  def update
    check_docked
    ship = current_user.active_spaceship

    # Update items which are not equipped anymore
    item_data = update_params[:ids] || {}
    ids = (Array(item_data[:main]) + Array(item_data[:utility])).compact
    render(json: {}, status: :ok) && (return) if ids.empty?

    ship.get_equipped_equipment.each do |item|
      loader = item.loader
      if !ids.include?(loader)
        # check black hole
        if item.loader.include?('equipment.storage') && (current_user.active_spaceship.get_weight > 0)
          raise InvalidRequest.new('errors.clear_storage_first')
        end

        Item::GiveToUser.(loader: loader, user: current_user, amount: 1)
        item.delete
      else
        ids -= [loader]
      end
    end

    ids.each do |loader|
      item = ship.items.where(loader: loader, equipped: false).first
      raise InvalidRequest unless item
      slot = item.get_attribute('slot_type')
      raise InvalidRequest if ship.send("get_free_#{slot}_slots").zero?

      if item.count > 1
        item.decrement!(:count)
        if item.get_attribute('slot_type') == 'main'
          Item.create(loader: item.loader, spaceship: ship, equipped: true)
        else
          Item.create(loader: item.loader, spaceship: item.spaceship, equipped: true)
        end
      else
        item.update(equipped: true)
      end
    end

    render json: { defense: ship.get_defense, storage: ship.get_storage_capacity, align: ship.get_align_time, target: ship.get_target_time }, status: :ok
  end

  def switch
    raise InvalidRequest unless params[:id]
    item = Item.ensure(params[:id])
    raise InvalidRequest unless item
    ship = current_user.reload.active_spaceship
    raise InvalidRequest unless ship

    raise InvalidRequest if !ship.get_main_equipment.map(&:id).include?(item.id) || !current_user.can_be_attacked?

    item.update(active: !item.active)

    if (ship.get_main_equipment(true).count == 1) && !current_user.equipment_worker
      EquipmentWorker.perform_async(current_user.id)
    end

    render json: { type: item.get_attribute('type') }, status: :ok
  end

  def info
    if params[:loader]
      render partial: 'equipment/info', locals: { item: params[:loader] }
    end
  end

  def update_params
    params.permit(ids: { main: [], utility: [] })
  end
end
