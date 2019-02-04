class PlayerDiedWorker
  # This worker will be run whenever a player died
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id) rescue nil
    
    return unless user
    
    # Tell user to show died modal
    ac_server.broadcast("player_#{user.id}", method: 'died_modal', text: I18n.t('modal.died_text', location: "#{user.location.get_name} - #{user.system_name}") )
    
  end
end