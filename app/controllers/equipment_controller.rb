class EquipmentController < ApplicationController
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
            
            # If item is not equipped
            if !item.equipped
              
              # Equip item
              if key == "main"
                if item.get_attribute('slot_type') == "main" and ship.get_free_main_slots > 0
                  item.update_columns(equipped: true)
                else
                  render json: {}, status: 400 and return
                end
              elsif key == "utility"
                if item.get_attribute('slot_type') == "utility" and ship.get_free_utility_slots > 0
                  item.update_columns(equipped: true)
                else
                  render json: {}, status: 400 and return
                end
              else
                render json: {}, status: 400 and return
              end
              
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
    
    render json: {power: ship.get_power, defense: ship.get_defense, storage: ship.get_storage_capacity, align: ship.get_align_time, target: ship.get_target_time}, status: 200 and return
  end
  
  def switch
    if params[:id] and (current_user.target || current_user.npc_target)
      item = Item.find(params[:id]) rescue nil
      if item and current_user.active_spaceship.get_main_equipment.map(&:id).include? item.id and current_user.can_be_attacked
        item.update_columns(active: !item.active)
        
        if current_user.reload.active_spaceship.get_main_equipment(true).count == 1
          if current_user.target
            AttackWorker.perform_async(current_user.id, current_user.target.id)
          else
            AttackNpcWorker.perform_async(current_user.id, current_user.npc_target.id)
          end
        end
        
        render json: {type: item.get_attribute('type'), usage: current_user.active_spaceship.get_septarium_usage}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
end