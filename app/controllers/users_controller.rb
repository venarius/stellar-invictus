class UsersController < ApplicationController
  def info
    if (user = User.ensure(params[:id]))
      render partial: 'info', locals: { user: user }
    else
      render html: ''
    end
  end

  def update_bio
    raise InvalidRequest if params[:text].nil?
    current_user.update_attribute('bio', params[:text])

    render json: {}, status: :ok
  end

  def place_bounty
    amount = params[:amount].to_i
    user = User.ensure(params[:id])
    raise InvalidRequest if (amount <= 0) || !user
    raise InvalidRequest.new('errors.minimum_amount_is_1k_credits') unless amount >= 1000
    raise InvalidRequest.new('errors.you_dont_have_enough_credits') unless current_user.units >= amount

    ActiveRecord::Base.transaction do
      current_user.reduce_units(amount)
      user.increment!(:bounty, amount)
    end
    user.broadcast(:notify_alert,
      text: I18n.t('notification.placed_bounty', user: current_user.full_name, amount: amount)
    )

    render json: {}, status: :ok
  end

end
