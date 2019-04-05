class UsersController < ApplicationController
  def info
    user = User.ensure(params[:id])
    if user
      render partial: 'info', locals: { user: user }
    else
      render html: ''
    end
  end

  def update_bio
    if params[:text]
      current_user.update_attribute('bio', params[:text])
      render(json: {}, status: :ok) && (return)
    end
    render json: {}, status: :bad_request
  end

  def place_bounty
    if params[:amount] && params[:id]
      amount = params[:amount].to_i rescue nil
      user = User.find(params[:id].to_i) rescue nil

      if amount && user
        # Check minimum
        render(json: { 'error_message': I18n.t('errors.minimum_amount_is_1k_credits') }, status: :bad_request) && (return) unless amount >= 1000

        # Check balance
        render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_credits') }, status: :bad_request) && (return) unless current_user.units >= amount

        current_user.reduce_units(amount)

        user.update(bounty: user.bounty + amount)

        user.broadcast(:notify_alert,
          text: I18n.t('notification.placed_bounty', user: current_user.full_name, amount: amount)
        )

        render(json: {}, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

end
