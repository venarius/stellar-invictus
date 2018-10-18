class FactionsController < ApplicationController
   before_action :authenticate_user!
   before_action :redirect_if_faction
   
   def index
      @factions = Faction.all
   end
   
   def choose_faction
      current_user.faction = Faction.find(params[:id])
      if !current_user.faction.nil? and current_user.save(validate: false)
         redirect_to root_path
      else
         flash[:error] = I18n.t('errors.something_went_wrong')
         redirect_to factions_path
      end
   end
   
   protected
   
   def redirect_if_faction
      redirect_to root_path if current_user.faction
   end
end