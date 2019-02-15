class StructuresController < ApplicationController
  
  include ApplicationHelper
  
  def open_container
    if params[:id]
      container = Structure.find_by(id: params[:id]) rescue nil
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
      structure = Structure.find(params[:id]) rescue nil
      if structure
        if params[:loader]
          items = Item.where(structure: structure, loader: params[:loader])
        else
          items = Item.where(structure: structure)
        end
        if items.present? and structure.location == current_user.location
          # Call police
          call_police(current_user) if structure.user != current_user and structure.structure_type != 'wreck' and !structure.user.in_same_fleet_as(current_user.id) and structure.created_at > (DateTime.now.to_time - 10.minutes).to_datetime
          
          # Check if player has enough space
          free_weight = current_user.active_spaceship.get_free_weight
          item_count = 0
          
          count = 0
          
          items.each do |item|
            item_count = item_count + item.count
            if (item.get_attribute('weight') * item.count) <= free_weight
              amount = (free_weight / item.get_attribute('weight')).round
              amount = item.count if amount > item.count
              Item.give_to_user({loader: item.loader, user: current_user, amount: amount})
              amount >= item.count ? item.destroy : item.update_columns(count: item.count - amount)
              free_weight = free_weight - item.get_attribute('weight') * amount
              count = count + amount
            end
          end
          
          # Destroy Structure if items gone and tell players to update players
          if Item.where(structure: params[:id]).empty?
            structure.destroy
            ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_appeared')
          end
          
          if count > 0
            if params[:loader] and count == item_count
              render json: {}, status: 200 and return
            else
              render json: {amount: item_count - free_weight}, status: 200 and return
            end
          else
            render json: {error_message: I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
          end
          
          render json: {}, status: 200 and return
        end
      end
    end
    render json: {}, status: 400
  end
  
  def attack
    if params[:id] and current_user.can_be_attacked
      structure = Structure.find(params[:id]) rescue nil
      if structure and structure.location == current_user.location
        # Call police
        call_police(current_user) if structure.user != current_user and structure.structure_type != 'wreck' and !structure.user.in_same_fleet_as(current_user.id) and structure.created_at > (DateTime.now.to_time - 10.minutes).to_datetime
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
  
  def abandoned_ship
    if params[:id] || (params[:id] and params[:text])
      structure = Structure.find(params[:id]) rescue nil
      if structure and structure.location == current_user.location and current_user.can_be_attacked
        if params[:text] and structure.items.present?
          if params[:text].downcase.include? Structure.riddles[structure.riddle]['answer']
            new_structure = Structure.create(location: current_user.location, structure_type: 'wreck')
            structure.items.update_all(structure_id: new_structure.id)
            render json: {}, status: 200 and return
          else
            rand(2..4).times do
              EnemyWorker.perform_async(nil, current_user.location.id)
            end
            structure.update_columns(attempts: structure.attempts + 1)
            if structure.attempts > 5
              structure.destroy
              ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_appeared')
              ActionCable.server.broadcast("player_#{current_user.id}", method: 'notify_alert', text: I18n.t('structures.abandoned_ship_selfdestruction') )
            end
          end
        else
          render partial: 'structures/abandoned_ship', locals: {structure: structure} and return
        end
      end
    end
    render json: {}, status: 400
  end
  
  def monument_info
    if params[:id]
      structure = Structure.find(params[:id]) rescue nil
      if structure and structure.location == current_user.location and current_user.can_be_attacked
        render partial: 'structures/monument', locals: {structure: structure} and return
      end
    end
    render json: {}, status: 400
  end
  
end