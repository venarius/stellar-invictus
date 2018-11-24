class NpcsController < ApplicationController
  def target
    if params[:id] and current_user.can_be_attacked
      target = Npc.find(params[:id]) rescue nil
      if target and target.location == current_user.location and current_user.npc_target != target
        TargetNpcWorker.perform_async(current_user.id, target.id)
        render json: {time: current_user.active_spaceship.get_target_time}, status: 200 and return
      end
    end
    render json: {time: current_user.active_spaceship.get_target_time}, status: 400
  end
  
  def untarget
    current_user.update_columns(npc_target_id: nil, is_attacking: false) if current_user.npc_target_id
    render json: {}, status: 200
  end
  
  def attack
    if params[:id] and current_user.can_be_attacked
      target = Npc.find(params[:id]) rescue nil
      if target and target.location == current_user.location and current_user.npc_target == target
        AttackNpcWorker.perform_async(current_user.id, target.id)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
end