class Corporation::AcceptApplication < ApplicationService
  required :application, ensure: CorpApplication

  def perform
    user = application.user
    corp = application.corporation

    user.update(corporation_role: :recruit, corporation: corp)
    corp.chat_room.users << user
    CorpApplication.where(user: user).destroy_all
    user.broadcast(:reload_corporation)
  end
end
