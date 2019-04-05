class MissionsController < ApplicationController

  before_action :get_mission, except: [:popup]

  # Render Info of mission
  def info
    if @mission.offered? || (@mission.active? && (@mission.user == current_user))
      render(partial: 'stations/missions/info', locals: { mission: @mission }) && (return)
    else
      render json: {}, status: :bad_request
    end
  end

  # Accept a mission
  def accept
    if @mission&.offered? && (@mission.location == current_user.location) && (current_user.missions.count < 5)

      Item::GiveToUser.(user: current_user, location: @mission.location, loader: @mission.mission_loader, amount: @mission.mission_amount) if @mission.delivery?

      @mission.active! && @mission.update(user_id: current_user.id)

      MissionGenerator.generate_missions(current_user.location.id)

      render(json: { message: I18n.t('missions.successfully_accepted_mission') }, status: :ok) && (return)
    end
    render json: {}, status: :bad_request
  end

  # Finish a mission
  def finish
    error = MissionGenerator.finish_mission(@mission.id)
    if error
      render json: { 'error_message': error }, status: :bad_request
    else
      render json: { message: I18n.t('missions.successfully_finished_mission') }, status: :ok
    end
  end

  # Abort a mission
  def abort
    if @mission.active? && (@mission.user == current_user)
      error = MissionGenerator.abort_mission(@mission.id)
      if error
        render json: { 'error_message': error }, status: :bad_request
      else
        render json: { message: I18n.t('missions.successfully_aborted_mission') }, status: :ok
      end
    else
      render json: {}, status: :bad_request
    end
  end

  # Popup
  def popup
    render partial: '/stations/missions/popup'
  end

  private

  def get_mission
    if params[:id]
      @mission = Mission.ensure(params[:id])
      unless @mission && current_user.docked
        render(json: {}, status: :bad_request) && (return)
      end
    end
  end

end
