class MissionsController < ApplicationController
  
  before_action :get_mission, except: [:popup]
  
  # Render Info of mission
  def info
    render partial: 'stations/missions/info', locals: {mission: @mission} and return
  end
  
  # Accept a mission
  def accept
    @mission.items.update_all(location_id: current_user.location.id, user_id: current_user.id) if @mission.delivery?
    
    @mission.active!
    render json: {}, status: 200 and return
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
    MissionGenerator.abort_mission(@mission.id)
    render json: {}, status: 200
  end
  
  # Popup
  def popup
    render partial: '/stations/missions/popup'
  end
  
  private
  
  def get_mission
    if params[:id]
      @mission = Mission.find(params[:id]) rescue nil
      unless @mission and @mission.user == current_user and current_user.docked
        render json: {}, status: 400 and return
      end
    end
  end
  
end