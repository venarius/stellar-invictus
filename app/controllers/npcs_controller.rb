class NpcsController < ApplicationController
  def target
    if params[:id] && current_user.can_be_attacked
      target = Npc.ensure(params[:id])
      if target && (target.location == current_user.location) && (current_user.npc_target != target)
        TargetNpcWorker.perform_async(current_user.id, target.id)
        render(json: { time: current_user.active_spaceship.get_target_time }, status: :ok) && (return)
      end
    end
    render json: { time: current_user.active_spaceship.get_target_time }, status: :bad_request
  end

  def untarget
    current_user.update_columns(npc_target_id: nil, is_attacking: false)
    current_user.active_spaceship.deactivate_equipment
    render json: {}, status: :ok
  end
end
