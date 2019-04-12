# == Schema Information
#
# Table name: polls
#
#  id                      :bigint(8)        not null, primary key
#  cached_votes_down       :integer          default(0)
#  cached_votes_score      :integer          default(0)
#  cached_votes_total      :integer          default(0)
#  cached_votes_up         :integer          default(0)
#  cached_weighted_average :float            default(0.0)
#  cached_weighted_score   :integer          default(0)
#  cached_weighted_total   :integer          default(0)
#  forum_link              :string
#  question                :string
#  status                  :integer          default("active")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Poll < ApplicationRecord
  acts_as_votable

  enum status: [:active, :waiting, :in_progress, :finished]

  def move_up
    case self.status
    when 'active'
      self.waiting!
    when 'waiting'
      self.in_progress!
    when 'in_progress'
      self.finished!
    end
  end

  def upvote_pct
    return 0 if total_votes.zero?
    ((self.get_upvotes.size.to_f / total_votes) * 100.0).round(1)
  end

  def downvote_pct
    return 0 if total_votes.zero?
    ((self.get_downvotes.size.to_f / total_votes) * 100.0).round(1)
  end

  def total_votes
    @total_votes ||= self.votes_for.size
  end

end
