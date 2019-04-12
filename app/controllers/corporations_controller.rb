class CorporationsController < ApplicationController

  def index
    @corporation = corp

    case params[:tab]
    when 'info'
      render partial: 'corporations/about'
    when 'roster'
      render partial: 'corporations/roster', locals: { corporation_users: @corporation.users }
    when 'finances'
      render partial: 'corporations/finances' if @corporation.can_deposit?(current_user)
    when 'applications'
      render partial: 'corporations/applications' if @corporation.can_see_applications?(current_user)
    when 'help'
      render partial: 'corporations/help'
    end
  end

  def sort_roster
    render partial: 'corporations/roster', locals: { corporation_users: corp.users.order("#{sort_column} #{sort_direction}") }
  end

  def new
    @corporation = Corporation.new
  end

  def create
    unless current_user.corporation
      corporation = Corporation.new(corporation_params)
      if corporation.save
        current_user.update(corporation_role: :founder, corporation: corporation)
        corporation.chat_room.users << current_user
        redirect_to corporations_path
      else
        @corporation = corporation
        render :new
      end
    end
  end

  def update_motd
    raise InvalidRequest if !corp || !params[:text] || !current_user.corporation.can_update_motd?(current_user)

    corp.update(motd: params[:text].to_s[0, 1000].strip)
    render json: { text: corp.motd, button_text: I18n.t('corporations.edit') }, status: :ok
  end

  def update_corporation
    raise InvalidRequest if !corp || !params[:tax] || !corp.is_founder?(current_user)

    if !corp.update(tax: params[:tax], bio: params[:about].to_s[0, 1000])
      raise InvalidRequest.new(corp.errors.full_messages.join(', '))
    end

    json = {
       tax: corp.tax,
       about: MARKDOWN.render(corp.bio),
       button_text: I18n.t('corporations.edit')
    }
    render(json: json, status: :ok)
   end

  def kick_user
    raise InvalidRequest unless corp
    user_to_kick = User.ensure(params[:id])
    raise InvalidRequest if !user_to_kick || !corp.is_member?(user_to_kick) || (!corp.can_kick_users?(current_user) && current_user != user_to_kick)
    if User.corporation_roles[user_to_kick.corporation_role] > User.corporation_roles[current_user.corporation_role]
      raise InvalidRequest.new('errors.cant_change_a_higher_rank')
    end

    result = Corporation::KickUser.(user: user_to_kick)
    raise InvalidRequest if result.failure?

    render(json: { reload: (result.value! == 0 || user_to_kick == current_user) }, status: :ok)
  end

  def change_rank_modal
    raise InvalidRequest unless corp
    user_with_rank = User.ensure(params[:id])
    raise InvalidRequest if !user_with_rank || !corp.is_member?(user_with_rank) || !corp.can_change_rank?(current_user)

    render partial: 'corporations/change_rank_modal', locals: { user: user_with_rank }
  end

  def change_rank
    raise InvalidRequest if !corp || !params[:rank]
    user_with_rank = User.ensure(params[:id])
    raise InvalidRequest if !user_with_rank || !corp.is_member?(user_with_rank) || !corp.can_change_rank?(current_user)

    rank = params[:rank].to_i

    if User.corporation_roles[current_user.corporation_role] < rank
      raise InvalidRequest.new('errors.cant_change_to_higher_rank_than_self')
    end
    if User.corporation_roles[user_with_rank.corporation_role] > User.corporation_roles[current_user.corporation_role]
      raise InvalidRequest.new('errors.cant_change_a_higher_rank')
    end
    if (user_with_rank == current_user) && user_with_rank.founder? && (user_with_rank.corporation.users.founder.count == 1)
      raise InvalidRequest.new('errors.cant_derank_only_founder')
    end

    user_with_rank.update(corporation_role: rank)
    render json: {}, status: :ok
  end

  def deposit_credits
    raise InvalidRequest if !corp || !params[:amount] || !corp.can_deposit?(current_user)

    amount = params[:amount].to_i

    raise InvalidRequest.new('errors.amount_must_be_bigger_than_0') unless amount > 0
    raise InvalidRequest.new('errors.you_dont_have_enough_credits') unless current_user.units >= amount

    ActiveRecord::Base.transaction do
      current_user.reduce_units(amount)
      corp.increment!(:units, amount)
      FinanceHistory.create(user: current_user, action: :deposit, amount: amount, corporation: corp)
    end

    render json: {}, status: :ok
  end

  def withdraw_credits
    raise InvalidRequest if !corp || !params[:amount] || !corp.can_withdraw?(current_user)

    amount = params[:amount].to_i

    raise InvalidRequest.new('errors.amount_must_be_bigger_than_0') unless amount > 0
    raise InvalidRequest.new('errors.corporation_dont_have_enough_credits') unless corp.units >= amount

    ActiveRecord::Base.transaction do
      current_user.increment!(:units, amount)
      corp.decrement!(:units, amount)
      FinanceHistory.create(user: current_user, action: :withdraw, amount: amount, corporation: corp)
    end

    render json: {}, status: :ok
  end

  def info
    corporation = Corporation.ensure(params[:id])
    if corporation
      render partial: 'corporations/info', locals: { corporation: corporation }
    else
      render html: ''
    end
  end

  def apply_modal
    corporation = Corporation.ensure(params[:id])
    if corporation
      render partial: 'corporations/apply_modal', locals: { corporation: corporation }
    else
      render html: ''
    end
  end

  def apply
    corporation = Corporation.ensure(params[:id])
    raise InvalidRequest unless corporation
    raise InvalidRequest.new('errors.already_in_corporation') if corporation.is_member?(current_user)

    CorpApplication.create(user: current_user, corporation: corporation, application_text: params[:text])

    render json: { message: I18n.t('corporations.received_application') }, status: :ok
  end

  # FIXME: There should be a separate controller for CorpApplications
  def accept_application
    raise InvalidRequest unless application.corporation.user_can_edit?(current_user)

    result = Corporation::AcceptApplication.(application: application)
    raise InvalidRequest.new(result.failure) if result.failure?

    render json: {}, status: :ok
  end

  def reject_application
    raise InvalidRequest unless application.corporation.can_reject_applications?(current_user)

    application.destroy

    render json: {}, status: :ok
  end

  def disband
    raise InvalidRequest unless corp.is_founder?(current_user)

    current_user.corporation.destroy

    render json: {}, status: :ok
  end

  def search
    raise InvalidRequest unless params[:search].present?

    result = Corporation.where('name ILIKE ?', "%#{params[:search]}%").first(20)
    render partial: 'corporations/search', locals: { corporations: result }
  end

  private

  def corp
    @corp ||= current_user.corporation
  end

  def application
    @application ||= begin
      app = CorpApplication.ensure(params[:id])
      raise InvalidRequest unless app
      app
    end
  end

  def corporation_params
    params.require(:corporation).permit(:name, :ticker, :bio, :tax)
  end

  def sortable_columns
    ['corporation_role', 'full_name', 'last_action']
  end

  def sort_column
    sortable_columns.include?(params[:column]) ? params[:column] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
