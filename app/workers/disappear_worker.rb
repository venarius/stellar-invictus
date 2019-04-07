class DisappearWorker < ApplicationWorker
  # This Worker will be run when the user logs off
  def perform(user_id, remove_logout = false)
    user = User.ensure(user_id)

    if (user.system.low? || user.system.wormhole?) && user.is_online? && !user.logout_timer
      user.update(logout_timer: true)
      DisappearWorker.perform_in(2.minutes, user.id, true)
    else
      User::Disappear.(user: user, remove_logout: remove_logout)
    end
  end
end
