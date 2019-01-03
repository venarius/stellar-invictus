class CorporationsController < ApplicationController
  
  def index
    @corporation = current_user.corporation
    
    # Render Tabs
    if params[:tab]
      case params[:tab]
      when 'info'
        render partial: 'corporations/about'
      when 'roster'
        render partial: 'corporations/roster'
      when 'finances'
        render partial: 'corporations/finances' if current_user.founder? || current_user.admiral?
      when 'applications'
        render partial: 'corporations/applications' if current_user.founder? || current_user.admiral? || current_user.commodore?
      when 'help'
        render partial: 'corporations/help'
      end
      return
    end
  end
  
  def new
    @corporation = Corporation.new
  end
  
  def create
    unless current_user.corporation
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
  end
  
  def update_motd
    if params[:text] and (current_user.founder? || current_user.admiral? || current_user.commodore? || current_user.lieutenant?)
      current_user.corporation.update_columns(motd: params[:text][0,1000])
      render json: {text: current_user.corporation.motd.strip, button_text: I18n.t('corporations.edit') }, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def update_corporation
    if params[:about] and params[:tax] and current_user.founder?
      tax = params[:tax].to_f rescue nil
      
      if tax
        tax = 100 if tax > 100
        tax = 0 if tax < 0
        
        current_user.corporation.update_columns(tax: tax, bio: params[:about][0,1000])
        render json: {tax: current_user.corporation.tax, about: MARKDOWN.render(current_user.corporation.bio), button_text: I18n.t('corporations.edit') }, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def kick_user
    if params[:id] and ((current_user.founder? || current_user.admiral? || current_user.commodore? || current_user.lieutenant?) || User.find(params[:id]) == current_user)
      corporation = current_user.corporation
      user = User.find(params[:id])
      
      if user
        # Check Permissions
        render json: {'error_message': I18n.t('errors.cant_change_a_higher_rank')}, status: 400 and return if User.corporation_roles[user.corporation_role] > User.corporation_roles[current_user.corporation_role]
        
        user.update_columns(corporation_id: nil, corporation_role: 0)
        ActionCable.server.broadcast("player_#{params[:id]}", method: 'reload_corporation')
        
        if corporation.users.count == 0
          corporation.destroy
        end
        
        render json: {reload: (corporation.users.count == 0 || User.find(params[:id]) == current_user) }, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def change_rank_modal
    if params[:id] and (current_user.founder? || current_user.admiral? || current_user.commodore? || current_user.lieutenant?)
      render partial: 'corporations/change_rank_modal', locals: {user: User.find(params[:id])}
    else
      render json: {}, status: 400
    end
  end
  
  def change_rank
    if params[:id] and params[:rank] and (current_user.founder? || current_user.admiral? || current_user.commodore? || current_user.lieutenant?)
      user = User.find(params[:id]) rescue nil
      rank = params[:rank].to_i rescue nil
      
      if user and rank and user.corporation_id == current_user.corporation_id
        
        # Check Permissions
        render json: {'error_message': I18n.t('errors.cant_change_to_higher_rank_than_self')}, status: 400 and return if User.corporation_roles[current_user.corporation_role] < rank
        
        # Check Permissions
        render json: {'error_message': I18n.t('errors.cant_change_a_higher_rank')}, status: 400 and return if User.corporation_roles[user.corporation_role] > User.corporation_roles[current_user.corporation_role]
        
        # Check Founder
        render json: {'error_message': I18n.t('errors.cant_derank_only_founder')}, status: 400 and return if user == current_user and user.founder? and user.corporation.users.where(corporation_role: 'founder').count == 1
        
        user.update_columns(corporation_role: rank)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def deposit_credits
    if params[:amount] and current_user.corporation and (current_user.founder? || current_user.admiral?)
      amount = params[:amount].to_i rescue nil
      
      if amount
        # Check Amount
        render json: {'error_message': I18n.t('errors.amount_must_be_bigger_than_0')}, status: 400 and return unless amount > 0
        
        # Check Balance
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.units >= amount
        
        current_user.reduce_units(amount)
        current_user.corporation.update_columns(units: current_user.corporation.units + amount)
        FinanceHistory.create(user: current_user, action: :deposit, amount: amount, corporation: current_user.corporation)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def withdraw_credits
    if params[:amount] and current_user.corporation and (current_user.founder? || current_user.admiral?)
      amount = params[:amount].to_i rescue nil
      
      if amount
        # Check Amount
        render json: {'error_message': I18n.t('errors.amount_must_be_bigger_than_0')}, status: 400 and return unless amount > 0
        
        # Check Balance
        render json: {'error_message': I18n.t('errors.corporation_dont_have_enough_credits')}, status: 400 and return unless current_user.corporation.units >= amount
        
        current_user.update_columns(units: current_user.units + amount)
        current_user.corporation.update_columns(units: current_user.corporation.units - amount)
        FinanceHistory.create(user: current_user, action: :withdraw, amount: amount, corporation: current_user.corporation)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def info
    corporation = Corporation.find(params[:id]) rescue nil
    if corporation
      render partial: 'corporations/info', locals: {corporation: corporation}
    else
      render html: ''
    end
  end
  
  def apply_modal
    corporation = Corporation.find(params[:id]) rescue nil
    if corporation
      render partial: 'corporations/apply_modal', locals: {corporation: corporation}
    else
      render html: ''
    end
  end
  
  def apply
    if params[:id] and params[:text]
      corporation = Corporation.find(params[:id]) rescue nil
      
      if corporation
        
        # Check if already in Corporation
        render json: {error_message: I18n.t('errors.already_in_corporation')}, status: 400 and return if corporation.users.where(id: current_user.id).present?
        
        CorpApplication.create(user: current_user, corporation: corporation, application_text: params[:text])
        render json: {message: I18n.t('corporations.received_application')}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def accept_application
    if params[:id] and (current_user.founder? || current_user.admiral? || current_user.commodore?)
      application = CorpApplication.find(params[:id]) rescue nil
      
      if application and application.corporation = current_user.corporation
        application.user.update_columns(corporation_role: :recruit, corporation_id: current_user.corporation_id)
        current_user.corporation.chat_room.users << application.user
        CorpApplication.where(user: application.user).destroy_all
        ActionCable.server.broadcast("player_#{application.user.id}", method: 'reload_corporation')
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def reject_application
    if params[:id] and (current_user.founder? || current_user.admiral? || current_user.commodore?)
      application = CorpApplication.find(params[:id]) rescue nil
      
      if application and application.corporation == current_user.corporation
        application.destroy
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def disband
    if current_user.founder? and current_user.corporation
      corporation = current_user.corporation
      
      corporation.users.each do |user|
        user.update_columns(corporation_id: nil, corporation_role: 0)
        ActionCable.server.broadcast("player_#{user.id}", method: 'reload_corporation')
      end
      
      if corporation.users.count == 0
        corporation.destroy
      end
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  private
  
  def corporation_params
    params.require(:corporation).permit(:name, :ticker, :bio, :tax)
  end
end