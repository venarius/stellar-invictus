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
