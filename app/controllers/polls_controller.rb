class PollsController < ApplicationController
  before_action :get_poll, only: [:upvote, :downvote, :move_up, :delete]
  before_action :check_voting_right, only: [:upvote, :downvote]
  
  def create
    if params[:question] and params[:link] and current_user.admin?
      Poll.create(status: :active, question: params[:question], forum_link: params[:link])
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def upvote
    @poll.upvote_from current_user if @poll.active?
    render json: {upvotes: ((@poll.get_upvotes.size.to_f / (@poll.votes_for.size / 100.0) rescue 0) rescue 0), downvotes: ((@poll.get_downvotes.size.to_f / (@poll.votes_for.size / 100.0) rescue 0) rescue 0), votes: @poll.votes_for.size}, status: 200
  end
  
  def downvote
    @poll.downvote_from current_user if @poll.active?
    render json: {upvotes: ((@poll.get_upvotes.size.to_f / (@poll.votes_for.size / 100.0) rescue 0) rescue 0), downvotes: ((@poll.get_downvotes.size.to_f / (@poll.votes_for.size / 100.0) rescue 0) rescue 0), votes: @poll.votes_for.size}, status: 200
  end
  
  def move_up
    @poll.move_up if current_user.admin
    render json: {}, status: 200
  end
  
  def delete
    @poll.destroy if current_user.admin
    render json: {}, status: 200
  end
  
  private
  
  def get_poll
    @poll = Poll.find(params[:id]) rescue nil
    render json: {}, status: 400 if @poll.nil?
  end
  
  def check_voting_right
    render json: {error_message: I18n.t('errors.need_1000_credits_to_be_eligible_to_vote')}, status: 400 if current_user.units < 1000
  end
  
end