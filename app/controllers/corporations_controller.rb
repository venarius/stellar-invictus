class CorporationsController < ApplicationController
  
  def index
    @corporation = current_user.corporation
  end
  
  def new
    @corporation = Corporation.new
  end
  
  def create
    corporation = Corporation.new(corporation_params)
    corporation.chat_room = ChatRoom.create(title: 'Corporation', chatroom_type: :corporation)
    if corporation.save
      current_user.update_columns(corporation_role: :founder, corporation_id: corporation.id)
      corporation.chat_room.users << current_user
      redirect_to corporation_path(corporation)
    else
      corporation.chat_room.destroy
      @corporation = corporation
      render :new
    end
  end
  
  def show
    @corporation = Corporation.find(params[:id]) rescue nil
  end
  
  def update_motd
    if params[:text] and current_user.founder?
      current_user.corporation.update_columns(motd: params[:text])
      render json: {text: current_user.corporation.motd, button_text: I18n.t('corporations.edit') }, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  private
  
  def corporation_params
    params.require(:corporation).permit(:name, :ticker, :bio, :tax_rate)
  end
end