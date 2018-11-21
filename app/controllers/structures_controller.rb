class StructuresController < ApplicationController
  def open_container
    if params[:id]
      container = Structure.find_by(id: params[:id])
      if container and container.location == current_user.location and current_user.can_be_attacked
        if container.container?
          render partial: 'structures/cargocontainer', locals: {items: container.get_items, container_id: container.id, owner_name: container.user.full_name}
          return
        elsif container.wreck?
          render partial: 'structures/cargocontainer', locals: {items: container.get_items, container_id: container.id, owner_name: ""}
          return
        end
      end
    end
    render json: {}, status: 400
  end
  
  def pickup_cargo
    if params[:id] and current_user.can_be_attacked
      structure = Structure.find(params[:id])
      if params[:loader]
        items = Item.where(structure: structure, loader: params[:loader])
      else
        items = Item.where(structure: structure)
      end
      if items.present? and structure.location == current_user.location
        # Call police
        call_police(current_user) if structure.user != current_user and structure.structure_type != 'wreck' and !structure.user.in_same_fleet_as(current_user.id)
        
        # Check if player has enough space
        weight = 0
        free_weight = current_user.active_spaceship.get_free_weight
        item_count = items.count
        items.each do |item|
          weight = weight + item.get_attribute('weight')
        end
        if weight > free_weight
          if free_weight > 0
            items.first(free_weight).each do |item|
              item.update_columns(structure_id: nil, spaceship_id: current_user.active_spaceship.id)
            end
            render json: {amount: item_count - free_weight}, status: 200 and return
          else
            render json: {error_message: I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
          end
        end
        
        # Update all items to spaceship
        items.update_all(structure_id: nil, spaceship_id: current_user.active_spaceship.id)
        
        # Destroy Structure if items gone and tell players to update players
        if Item.where(structure: params[:id]).empty?
          structure.destroy
          ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_appeared')
        end
        
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def attack
    if params[:id] and current_user.can_be_attacked
      structure = Structure.find(params[:id])
      if structure.location == current_user.location
        # Call police
        call_police(current_user) if structure.user != current_user and structure.structure_type != 'wreck'
        # Destroy Structure
        structure.destroy
        # Tell Players in location
        ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_appeared')
        ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'log', text: I18n.t('log.user_destroyed_cargo', user: current_user.full_name))
        
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
end