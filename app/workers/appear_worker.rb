class AppearWorker
  # This Worker will be run when the user loggs in

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user)
    User::Appear.(user: user)
  end
end
