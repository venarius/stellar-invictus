class FactionsController < ApplicationController
  before_action :redirect_if_faction, except: [:choose_faction]
  skip_before_action :redirect_if_no_faction
  
  def index
    @factions = Faction.all
  end
  
  def choose_faction
    if !current_user.faction
      faction = Faction.find(params[:id]) rescue nil
      rand_location = faction.locations.order(Arel.sql("RANDOM()")).first rescue nil
      if faction and rand_location and current_user.update_columns(faction_id: faction.id, location_id: rand_location.id, system_id: rand_location.system.id, docked: true)
        
        # Give player ship and equipment
        current_user.give_nano
        
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