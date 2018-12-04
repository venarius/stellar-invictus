class EquipmentController < ApplicationController
  
  include ApplicationHelper
  
  # Update
  def update
    ship = current_user.active_spaceship
    
    # Return if current user is not docked
    render json: {}, status: 400 and return if !current_user.docked
    
    if params[:ids]
      params[:ids].each do |key, value|
        value.each do |id|
          
          # Find item with id
          item = Item.find(id) rescue nil
          
          # Item and item belongs to spaceship and item's spaceship is ship of user
          if item and item.spaceship and item.spaceship == ship
              
            # Equip item
            if key == "main"
              if item.get_attribute('slot_type') == "main"
                if !item.equipped
                  if ship.get_free_main_slots > 0
                    item.update_columns(equipped: true)
                  else 
                    render json: {}, status: 400 and return
                  end
                end
              else
                render json: {}, status: 400 and return
              end
            elsif key == "utility"
              if item.get_attribute('slot_type') == "utility"
                if !item.equipped
                  if ship.get_free_utility_slots > 0
                    item.update_columns(equipped: true)
                  else 
                    render json: {}, status: 400 and return
                  end
                end
              else
                render json: {}, status: 400 and return
              end
            else
              render json: {}, status: 400 and return
            end
              
          else
            render json: {}, status: 400 and return
          end
        end
      end
    end
    
    # Update ship var
    ship = current_user.active_spaceship
    
    # Update items which are not equipped anymore
    ids = []
    if params[:ids]
      ids = ids + params[:ids][:main] if params[:ids][:main]
      ids = ids + params[:ids][:utility] if params[:ids][:utility]
    end
    ship.get_equipped_equipment.each do |item|
      item.update_columns(equipped: false) if !ids or !ids.include? item.id.to_s
    end
    
    render json: {defense: ship.get_defense, storage: ship.get_storage_capacity, align: ship.get_align_time, target: ship.get_target_time}, status: 200 and return
  end
  
  def switch
    if params[:id]
      item = Item.find(params[:id]) rescue nil
      if item and current_user.active_spaceship.get_main_equipment.map(&:id).include? item.id and current_user.can_be_attacked
        item.update_columns(active: !item.active)
        
        if current_user.reload.active_spaceship.get_main_equipment(true).count == 1
          EquipmentWorker.perform_async(current_user.id)
        end
        
        render json: {type: item.get_attribute('type'), usage: current_user.active_spaceship.get_septarium_usage}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def craft
    if params[:loader] and current_user.docked
      ressources = get_item_attribute(params[:loader], 'crafting')
      if ressources
        # Check if has ressources
        ressources.each do |key, value|
          items = Item.where(loader: key, user: current_user)
          render json: {'error_message': I18n.t('errors.not_required_material')}, status: 400 and return if !items.present? || items.count < value
        end
        
         Delete ressources
        ressources.each do |key, value|
          Item.where(loader: key, user: current_user).limit(value).destroy_all
        end
        
        # Create CraftJob
        CraftJob.create(completion: DateTime.now + (get_item_attribute(params[:loader], 'crafting_duration').to_f/1440.0), loader: params[:loader], user: current_user, location: current_user.location)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
end