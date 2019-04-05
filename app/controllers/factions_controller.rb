class FactionsController < ApplicationController
  before_action :redirect_if_faction, except: [:choose_faction]
  skip_before_action :redirect_if_no_faction

  def index
    @factions = Faction.all
  end

  def choose_faction
    faction = Faction.ensure(params[:id])
    if faction && !current_user.faction
      rand_location = faction.locations.station.order(Arel.sql("RANDOM()")).first
      if rand_location && current_user.update(faction: faction, location: rand_location, system: rand_location.system, docked: true)

        # Give player ship and equipment
        current_user.give_nano

        # Add user to rookie channel
        ChatRoom.ensure('ROOKIES').users << current_user

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
