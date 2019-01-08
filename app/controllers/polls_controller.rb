class PollsController < ApplicationController
  before_action :get_poll, only: [:upvote, :downvote, :move_up, :delete]
  
  def create
    if params[:question] and params[:link] and current_user.admin?
      Poll.create(status: :active, question: params[:question], forum_link: params[:link])
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def upvote
    @poll.upvote_from current_user
    render json: {upvotes: ((100 / (@poll.get_upvotes.size.to_f / @poll.votes_for.size) rescue 0) rescue 0), downvotes: ((100 / (@poll.get_downvotes.size.to_f / @poll.votes_for.size) rescue 0) rescue 0), votes: @poll.votes_for.size}, status: 200
  end
  
  def downvote
    @poll.downvote_from current_user
    render json: {upvotes: ((100 / (@poll.get_upvotes.size.to_f / @poll.votes_for.size) rescue 0) rescue 0), downvotes: ((100 / (@poll.get_downvotes.size.to_f / @poll.votes_for.size) rescue 0) rescue 0), votes: @poll.votes_for.size}, status: 200
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
    if params[:id]
      @poll = Poll.find(params[:id]) rescue nil
      render json: {}, status: 400 unless @poll
    end
  end
  
end