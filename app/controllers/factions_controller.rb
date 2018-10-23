class FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_faction, except: [:choose_faction]
  skip_before_action :redirect_if_no_faction
  
  def index
    @factions = Faction.all
  end
  
  def choose_faction
    if !current_user.faction
      current_user.faction = Faction.find(params[:id])
      # TODO Temporary 22.10.2018
      current_user.system = System.first
      if current_user.faction and current_user.save(validate: false)
        redirect_to game_path
      else
        flash[:error] = I18n.t('errors.something_went_wrong')
        redirect_to factions_path
      end
    else
      redirect_to game_path
    end
  end
  
  protected
  
  def redirect_if_faction
    redirect_to game_path if current_user.faction
  end
end