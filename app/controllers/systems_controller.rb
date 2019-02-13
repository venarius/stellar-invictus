class SystemsController < ApplicationController
  
  def info
    if params[:id]
      system = System.find(params[:id]) rescue nil
      if system
        render partial: 'systems/info', locals: {sys: system} and return
      end
    end
    render json: {}, status: 400
  end
  
  def route
    if params[:id]
      system = System.find(params[:id]) rescue nil
      if system and !current_user.system.wormhole?
        old_route = current_user.route
        path = Pathfinder.find_path(current_user.system.id, system.id)
        
        jumpgates = []
        path.each_with_index do |step, index|
          location = System.find_by(name: step).locations.where("name ilike ?", path[index+1]).first
          jumpgates << location.jumpgate.id if location
        end
        
        current_user.update_columns(route: jumpgates)
        render json: {old_route: old_route, route: jumpgates, card: render_to_string(partial: 'systems/route_card') }, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def clear_route
    old_route = current_user.route
    current_user.update_columns(route: [])
    render json: {route: old_route}, status: 200
  end
  
  def scan
    scanner_range = current_user.active_spaceship.get_scanner_range
    if scanner_range and current_user.can_be_attacked
      # check count
      render json: {error_message: I18n.t('errors.no_exploration_sites_found')}, status: 400 and return if current_user.system.locations.where(hidden: true).count == 0
      
      render partial: 'game/locations_table', locals: {locations: current_user.system.locations.where(hidden: true).limit(scanner_range)}
    else
      render json: {}, status: 400
    end
  end
  
  def directional_scan
    scanner_range = current_user.active_spaceship.get_scanner_range
    
    if current_user.can_be_attacked
      locations = {}
      current_user.system.locations.where(hidden: false).each do |loc|
        locations[loc.id] = loc.users.where.not(online: 0).count + loc.npcs.count
      end
      
      if scanner_range
        current_user.system.locations.where(hidden: true).limit(scanner_range).each do |loc|
          locations[loc.id] = loc.users.where.not(online: 0).count + loc.npcs.count
        end
      end
      
      render json: {locations: locations}, status: 200 and return
    end
    render json: {}, status: 400
  end
end