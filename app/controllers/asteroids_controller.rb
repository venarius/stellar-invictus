class AsteroidsController < ApplicationController

  def mine
    svc_result = Asteroid::Mine.(user: current_user, asteroid: params[:id])
    if svc_result.failure?
      render json: { error_message: svc_result.failure }, status: :bad_request
    else
      render json: svc_result.value!, status: :ok
    end
  end

  def stop_mine
    current_user.update(mining_target_id: nil)
    render json: {}, status: :ok
  end

end
