class UsersController < ApplicationController
  def info
    user = User.find(params[:id]) rescue nil
    if user
      render partial: 'info', locals: {user: user}
    else
      render html: ''
    end
  end
end