class NpcsController < ApplicationController
  def target
    if params[:id] and current_user.can_be_attacked
      target = Npc.find(params[:id])
      if target and target.location == current_user.location
        TargetNpcWorker.perform_async(current_user.id, target.id)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def attack
    if params[:id] and current_user.can_be_attacked
      target = Npc.find(params[:id])
      if target and target.location == current_user.location and current_user.npc_target == target
        AttackNpcWorker.perform_async(current_user.id, target.id)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
end