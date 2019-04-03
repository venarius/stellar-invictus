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
    when "active"
      self.waiting!
    when "waiting"
      self.in_progress!
    when "in_progress"
      self.finished!
    end
  end

end
