class Corporation::KickUser < ApplicationService
  required :user, ensure: User

  def perform
    corp = user.corporation
    user.update(corporation_id: nil, corporation_role: :recruit)
    user.broadcast(:reload_corporation)
    corp.chat_room.users.destroy(user)

    user_count = corp.users.count
    corp.destroy if user_count == 0

    user_count
  end
end
