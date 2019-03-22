class MissionsController < ApplicationController

  before_action :get_mission, except: [:popup]

  # Render Info of mission
  def info
    if @mission.offered? || (@mission.active? && (@mission.user == current_user))
      render(partial: 'stations/missions/info', locals: { mission: @mission }) && (return)
    else
      render json: {}, status: 400
    end
  end

  # Accept a mission
  def accept
    if @mission&.offered? && (@mission.location == current_user.location) && (current_user.missions.count < 5)

      Item.give_to_user(user: current_user, location: @mission.location, loader: @mission.mission_loader, amount: @mission.mission_amount) if @mission.delivery?

      @mission.active! && @mission.update_columns(user_id: current_user.id)

      MissionGenerator.generate_missions(current_user.location.id)

      render(json: { message: I18n.t('missions.successfully_accepted_mission') }, status: 200) && (return)
    end
    render json: {}, status: 400
  end

  # Finish a mission
  def finish
    error = MissionGenerator.finish_mission(@mission.id)
    if error
      render json: { 'error_message': error }, status: 400
    else
      render json: { message: I18n.t('missions.successfully_finished_mission') }, status: 200
    end
  end

  # Abort a mission
  def abort
    if @mission.active? && (@mission.user == current_user)
      error = MissionGenerator.abort_mission(@mission.id)
      if error
        render json: { 'error_message': error }, status: 400
      else
        render json: { message: I18n.t('missions.successfully_aborted_mission') }, status: 200
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
      unless @mission && current_user.docked
        render(json: {}, status: 400) && (return)
      end
    end
  end

end
