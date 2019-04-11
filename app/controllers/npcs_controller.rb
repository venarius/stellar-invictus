class NpcsController < ApplicationController
  def target
    target = Npc.ensure(params[:id])
    raise InvalidRequest.new(time: current_user.active_spaceship.get_target_time) unless target
    raise InvalidRequest.new(time: current_user.active_spaceship.get_target_time) unless current_user.can_be_attacked?
    raise InvalidRequest.new(time: current_user.active_spaceship.get_target_time) unless target.location_id == current_user.location_id
    raise InvalidRequest.new(time: current_user.active_spaceship.get_target_time) unless current_user.npc_target_id != target.id

    TargetNpcWorker.perform_async(current_user.id, target.id)
    render json: { time: current_user.active_spaceship.get_target_time }, status: :ok
  end

  def untarget
    current_user.update(npc_target_id: nil, is_attacking: false)
    current_user.active_spaceship.deactivate_equipment
    render json: {}, status: :ok
  end
end
