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
end