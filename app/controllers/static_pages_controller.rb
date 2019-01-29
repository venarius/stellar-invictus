class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :credits, :nojs]
  skip_before_action :redirect_if_no_faction, only: [:home, :credits, :nojs, :create_support_ticket]
  
  def home
  end
  
  def credits
  end
  
  def nojs
  end
  
  def map
  end
  
  def create_support_ticket
    ApplicationMailer.with(category: params[:ticket][:category], subject: params[:ticket][:subject], description: params[:ticket][:description], name: current_user.full_name).support_ticket.deliver_now
    render json: {message: I18n.t('support.mail_sent_successfully')}, status: 200
  end
  
  def donate
  end
end