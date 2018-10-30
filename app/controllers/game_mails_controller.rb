class GameMailsController < ApplicationController
  def index
    @inbox = GameMail.includes(:sender, :recipient).where(recipient: current_user)
    @sent = GameMail.includes(:sender, :recipient).where(sender: current_user)
  end

  def new
    @mail = GameMail.new
  end
  
  def create
    recipient = User.where(full_name: mail_params[:recipient_name]).first
    if recipient && GameMail.create(sender: current_user, recipient: recipient, body: mail_params[:body], header: mail_params[:header], units: mail_params[:units])
      flash[:notice] = I18n.t('mails.successfully_sent')
      redirect_to game_mails_path
    else
      flash[:alert] = I18n.t('errors.recipient_not_found')
      @mail = GameMail.new(body: mail_params[:body], header: mail_params[:header])
      render :new
    end
  end
  
  def show
    mail = GameMail.find(params[:id]) rescue nil
    if mail
      if mail.recipient == current_user || mail.sender == current_user
        render partial: 'game_mails/show', locals: {mail: mail}
      else
        redirect_to game_mails_path
      end
    else
      redirect_to game_mails_path
    end
  end
  
  def inbox
    render partial: 'game_mails/mail_list', locals: {mails: GameMail.includes(:sender, :recipient).where(recipient: current_user)}
  end
  
  private
  
  def mail_params
    params.require(:game_mail).permit(:recipient_name, :body, :header, :units)
  end
end