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
    
    render json: {power: ship.get_power, defense: ship.get_defense, storage: ship.get_storage_capacity, align: ship.get_align_time}, status: 200 and return
  end
  render json: {}, status: 400
end