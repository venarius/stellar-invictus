class MarketController < ApplicationController
  def list
    if params[:loader] and current_user.docked
      listings = MarketListing.where(location: current_user.location).where("loader like ?", "%#{params[:loader]}%")
      render partial: 'stations/market/list', locals: {market_listings: listings} and return
    end
    render json: {}, status: 400
  end
  
  def search
    if params[:search] and current_user.docked
      listings = MarketListing.where(location: current_user.location).where("loader like ?", "%#{params[:search].downcase.gsub(' ', '_')}%")
      render partial: 'stations/market/list', locals: {market_listings: listings} and return
    end
    render json: {}, status: 400
  end
end