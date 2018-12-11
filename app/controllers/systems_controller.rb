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
        path = Pathfinder.find_path(current_user.system.id, system.id)
        
        jumpgates = []
        path.each_with_index do |step, index|
          location = System.find_by(name: step).locations.where(name: path[index+1]).first
          jumpgates << location.jumpgate.id if location
        end
        
        current_user.update_columns(route: jumpgates)
        render json: {"route": jumpgates}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def clear_route
    current_user.update_columns(route: [])
    render json: {}, status: 200
  end
end