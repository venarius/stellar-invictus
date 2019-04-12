class FactionsController < ApplicationController
  skip_before_action :redirect_if_no_faction

  def index
    redirect_to game_path if current_user.faction
    @factions = Faction.all
  end

  def choose_faction
    faction = Faction.ensure(params[:id])
    raise RedirectRequest.new(game_path, error: 'Haste makes waste') if !faction || current_user.faction

    rand_location = faction.locations.station.random_row
    raise RedirectRequest.new(factions_path, error: 'errors.something_went_wrong') if !rand_location

    if !current_user.update(faction: faction, location: rand_location, docked: true)
      raise RedirectRequest.new(factions_path, error: 'errors.something_went_wrong')
    end

    # Give player ship and equipment
    current_user.give_nano

    # Add user to rookie channel
    ChatRoom.ensure('ROOKIES').users << current_user

    redirect_to game_path
  end
end
