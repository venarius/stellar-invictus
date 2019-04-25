class PlayerDiedWorker < ApplicationWorker
  def perform(player_id)
    # debug_args(player_id: player_id)
    player = User.ensure(player_id)

    # Tell user to show died modal
    player&.broadcast(:died_modal,
      text: I18n.t('modal.died_text', location: player.location.full_name)
    )
  end
end
