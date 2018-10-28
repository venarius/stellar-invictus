class MailsController < ApplicationController
  def index
    @inbox = Mail.includes(:sender, :recipient).where(recipient: current_user)
    @sent = Mail.includes(:sender, :recipient).where(sender: current_user)
  end

  def new
    @mail = Mail.new
  end
  
  def create
    name_strip = mail_params[:recipient_name].strip.split(" ")
    recipient = User.where(name: name_strip[0], family_name: name_strip[1]).first
    if recipient && Mail.create(sender: current_user, recipient: recipient, body: mail_params[:body], header: mail_params[:header], units: mail_params[:units])
      flash[:notice] = I18n.t('mails.successfully_sent')
      redirect_to mails_path
    else
      flash[:alert] = I18n.t('errors.recipient_not_found')
      @mail = Mail.new(body: mail_params[:body], header: mail_params[:header])
      render :new
    end
  end
  
  def show
    mail = Mail.find(params[:id])
    if mail
      if mail.recipient == current_user || mail.sender == current_user
        render partial: 'mails/show', locals: {mail: mail}
      else
        redirect_to mails_path
      end
    else
      redirect_to mails_path
    end
  end
  
  private
  
  def mail_params
    params.require(:mail).permit(:recipient_name, :body, :header, :units)
  end
end