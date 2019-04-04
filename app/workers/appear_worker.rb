class AppearWorker < ApplicationWorker
  # This Worker will be run when the user logs in
  def perform(user)
    User::Appear.(user: user)
  end
end
