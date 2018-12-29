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
      redirect_to corporations_path
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
      render json: {text: current_user.corporation.motd.strip, button_text: I18n.t('corporations.edit') }, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def update_corporation
    if params[:about] and params[:tax] and current_user.founder?
      current_user.corporation.update_columns(tax: params[:tax].to_f, bio: params[:about])
      render json: {tax: current_user.corporation.tax, about: MARKDOWN.render(current_user.corporation.bio), button_text: I18n.t('corporations.edit') }, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def kick_user
    if params[:id] and (current_user.founder? || User.find(params[:id]) == current_user)
      corporation = current_user.corporation
      corporation.users.delete(User.find(params[:id]))
      
      if corporation.users.count == 0
        corporation.destroy
      end
      
      render json: {reload: (corporation.users.count == 0 || User.find(params[:id]) == current_user) }, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def change_rank_modal
    if params[:id] and current_user.founder?
      render partial: 'corporations/change_rank_modal', locals: {user: User.find(params[:id])}
    end
  end
  
  def change_rank
    if params[:id] and params[:rank]
      user = User.find(params[:id]) rescue nil
      rank = params[:rank].to_i rescue nil
      
      if user and rank
        
        # check permissions
        render json: {'error_message': I18n.t('errors.cant_change_to_higher_rank_than_self')}, status: 400 and return if User.corporation_roles[current_user.corporation_role] < rank
        
        # check founder
        render json: {'error_message': I18n.t('errors.cant_derank_only_founder')}, status: 400 and return if user == current_user and user.founder? and user.corporation.users.where(corporation_role: 'founder').count == 1
        
        user.update_columns(corporation_role: rank)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  private
  
  def corporation_params
    params.require(:corporation).permit(:name, :ticker, :bio, :tax_rate)
  end
end