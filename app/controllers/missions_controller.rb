class MissionsController < ApplicationController

  def info
    raise InvalidRequest if !mission.offered? && !(mission.active? && (mission.user_id == current_user.id))

    render partial: 'stations/missions/info', locals: { mission: mission }, status: :ok
  end

  def accept
    raise InvalidRequest if !mission.offered? || (mission.location_id != current_user.location_id) || (current_user.missions.count >= 5)

    Item::GiveToUser.(user: current_user, location: mission.location, loader: mission.mission_loader, amount: mission.mission_amount) if mission.delivery?

    mission.active! && mission.update(user_id: current_user.id)

    MissionGenerator.generate_missions(current_user.location.id)

    render json: { message: I18n.t('missions.successfully_accepted_mission') }, status: :ok
  end

  def finish
    error = MissionGenerator.finish_mission(mission.id)
    raise InvalidRequest.new(error) if error

    render json: { message: I18n.t('missions.successfully_finished_mission') }, status: :ok
  end

  def abort
    raise InvalidRequest if !mission.active? || (mission.user_id != current_user.id)

    error = MissionGenerator.abort_mission(mission.id)
    raise InvalidRequest.new(error) if error

    render json: { message: I18n.t('missions.successfully_aborted_mission') }, status: :ok
  end

  def popup
    render partial: '/stations/missions/popup'
  end

  private

  def mission
    raise InvalidRequest unless current_user.docked?
    @mission ||= begin
      record = Mission.ensure(params[:id])
      raise InvalidRequest unless record
      record
    end
  end

end
