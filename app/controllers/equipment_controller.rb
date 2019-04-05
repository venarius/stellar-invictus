class EquipmentController < ApplicationController

  include ApplicationHelper

  # Update
  def update
    ship = current_user.active_spaceship

    # Return if current user is not docked
    render(json: {}, status: :bad_request) && (return) if !current_user.docked

    # Update items which are not equipped anymore
    ids = []
    if params[:ids]
      ids += Array(params[:ids][:main]) + Array(params[:ids][:utility])
    end

    ship.get_equipped_equipment.each do |item|
      loader = item.loader
      if !ids&.include?(loader)
        # check black hole
        if item.loader.include?("equipment.storage") && (current_user.active_spaceship.get_weight > 0)
          render(json: { error_message: I18n.t('errors.clear_storage_first') }, status: :bad_request) && (return)
        end

        Item::GiveToUser.(loader: loader, user: current_user, amount: 1)
        item.delete
      else
        ids -= [loader]
      end
    end

    ids.each do |loader|
      # Find item with id
      item = ship.items.where(loader: loader, equipped: false).first

      # Item and item belongs to spaceship and item's spaceship is ship of user
      if item
        # Equip item
        if item.get_attribute('slot_type') == "main"
          if ship.get_free_main_slots > 0
            if item.count > 1
              item.update(count: item.count - 1)
              Item.create(loader: item.loader, spaceship: ship, equipped: true)
            else
              item.update(equipped: true)
            end
          else
            render(json: {}, status: :bad_request) && (return)
          end
        elsif item.get_attribute('slot_type') == "utility"
          if ship.get_free_utility_slots > 0
            if item.count > 1
              item.update(count: item.count - 1)
              Item.create(loader: item.loader, spaceship: item.spaceship, equipped: true)
            else
              item.update(equipped: true)
            end
          else
            render(json: {}, status: :bad_request) && (return)
          end
        else
          render(json: {}, status: :bad_request) && (return)
        end

      else
        render(json: {}, status: :bad_request) && (return)
      end
    end

    render(json: { defense: ship.get_defense, storage: ship.get_storage_capacity, align: ship.get_align_time, target: ship.get_target_time }, status: :ok) && (return)
  end

  def switch
    if params[:id]
      item = Item.ensure(params[:id])
      if item && current_user.active_spaceship&.get_main_equipment.map(&:id).include?(item.id) && current_user.can_be_attacked
        item.update(active: !item.active)

        if (current_user.reload.active_spaceship.get_main_equipment(true).count == 1) && !current_user.equipment_worker
          EquipmentWorker.perform_async(current_user.id)
        end

        render(json: { type: item.get_attribute('type') }, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  def info
    if params[:loader]
      render partial: 'equipment/info', locals: { item: params[:loader] }
    end
  end
end
