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
      if system
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
    scanner = current_user.active_spaceship.get_scanner
    if scanner and current_user.can_be_attacked
      render partial: 'game/locations_table', locals: {locations: current_user.system.locations.where(hidden: true).limit(scanner.get_attribute('scanner_range'))}
    else
      render json: {}, status: 400
    end
  end
end