class UsersController < ApplicationController
  def info
    user = User.find(params[:id]) rescue nil
    if user
      render partial: 'info', locals: {user: user}
    else
      render html: ''
    end
  end
  
  def update_bio
    if params[:text]
      current_user.update_attribute('bio', params[:text])
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def place_bounty
    if params[:amount] and params[:id]
      amount = params[:amount].to_i rescue nil
      user = User.find(params[:id].to_i) rescue nil
      
      if amount and user
        # Check minimum
        render json: {'error_message': I18n.t('errors.minimum_amount_is_1k_credits')}, status: 400 and return unless amount >= 1000
        
        # Check balance
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.units >= amount
        
        current_user.reduce_units(amount)
        
        user.update_columns(bounty: user.bounty + amount)
        
        ActionCable.server.broadcast("player_#{user.id}", method: 'notify_alert', text: I18n.t('notification.placed_bounty', user: current_user.full_name, amount: amount))
        
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
end