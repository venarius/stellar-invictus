class MissionsController < ApplicationController
  
  before_action :get_mission, except: [:popup]
  
  # Render Info of mission
  def info
    if @mission.offered? || (@mission.active? and @mission.user == current_user)
      render partial: 'stations/missions/info', locals: {mission: @mission} and return
    else
      render json: {}, status: 400
    end
  end
  
  # Accept a mission
  def accept
    if @mission.offered? and @mission.location == current_user.location and current_user.missions.count < 5
      
      @mission.items.update_all(location_id: current_user.location.id, user_id: current_user.id) if @mission.delivery?
      
      @mission.active! and @mission.update_columns(user_id: current_user.id)
      
      MissionGenerator.generate_missions(current_user.location.id)
      
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  # Finish a mission
  def finish
    error = MissionGenerator.finish_mission(@mission.id)
    if error
      render json: {'error_message': error}, status: 400
    else
      render json: {}, status: 200
    end
  end
  
  # Abort a mission
  def abort
    if @mission.active? and @mission.user == current_user
      error = MissionGenerator.abort_mission(@mission.id)
      if error
        render json: {'error_message': error}, status: 400
      else
        render json: {}, status: 200
      end
    else
      render json: {}, status: 400
    end
  end
  
  # Popup
  def popup
    render partial: '/stations/missions/popup'
  end
  
  private
  
  def get_mission
    if params[:id]
      @mission = Mission.find(params[:id]) rescue nil
      unless @mission and current_user.docked
        render json: {}, status: 400 and return
      end
    end
  end
  
end