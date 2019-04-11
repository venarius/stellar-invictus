class PollsController < ApplicationController

  def create
    raise InvalidRequest if !params[:question] || !params[:link] || !current_user.admin?

    Poll.create(status: :active, question: params[:question], forum_link: params[:link])
    render json: {}, status: :ok
  end

  def upvote
    poll
    raise InvalidRequest.new('errors.need_1000_credits_to_be_eligible_to_vote') if current_user.units < 1000
    poll.upvote_from current_user if poll.active?
    render json: { upvotes: poll.upvote_pct, downvotes: poll.downvote_pct, votes: poll.votes_for.size }, status: :ok
  end

  def downvote
    poll
    raise InvalidRequest.new('errors.need_1000_credits_to_be_eligible_to_vote') if current_user.units < 1000
    poll.downvote_from current_user if poll.active?
    render json: { upvotes: poll.upvote_pct, downvotes: poll.downvote_pct, votes: poll.votes_for.size }, status: :ok
  end

  def move_up
    poll
    poll.move_up if current_user.admin?
    render json: {}, status: :ok
  end

  def delete
    poll
    poll.destroy if current_user.admin?
    render json: {}, status: :ok
  end

  private

  def poll
    @poll ||= begin
      record = Poll.ensure(params[:id])
      raise InvalidRequest unless record
      record
    end
  end
end
