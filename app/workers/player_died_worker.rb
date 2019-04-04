class PlayerDiedWorker < ApplicationWorker
  def perform(player)
    player = User.ensure(player)
    return unless player

    # Tell user to show died modal
    player.broadcast(:died_modal, text: I18n.t('modal.died_text', location: "#{player.location.get_name} - #{player.system_name}"))
  end
end
