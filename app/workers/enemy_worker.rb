class EnemyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(location_id)
    location = Location.find(location_id)
    
    enemy = Npc.create(npc_type: 'enemy', location: location, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}", hp: 30)
    
    # Tell everyone in the location that an enemy has spawned
    ActionCable.server.broadcast("location_#{location.id}", method: 'player_appeared')
    
    sleep(3)
    
    # Find first User in system and target
    target = User.where(location: location, docked: false).where('online > 0').first rescue nil
    
    if target
      attack(enemy, target)
    else
      wait_for_new_target(enemy)
    end
    
  end
  
  # ################
  # NPC can attack?
  # ################
  def can_attack(enemy, target)
    enemy = enemy.reload rescue nil
    target = target.reload rescue nil
    
    if enemy and target
      target.can_be_attacked and target.location == enemy.location
    else
      return false
    end
  end
  
  # ################
  # Wait for new target
  # ################
  def wait_for_new_target(enemy)
    sleep(10)
    
    # Find first User in system and target
    target = User.where(location: location, docked: false).where('online > 0').first rescue nil
    
    if target
      attack(enemy, target)
    else
      enemy.destroy and return
    end
  end
  
  # ################
  # Attack
  # ################
  def attack(enemy, target)
    enemy.update_columns(target: target.id)
      
    # Tell user he is getting targeted by outlaw
    ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: enemy.name)
    
    sleep(3)
    
    # Tell user he is getting attacked by police
    ActionCable.server.broadcast("player_#{target.id}", method: 'getting_attacked', name: enemy.name)
    
    # While npc can attack player
    while can_attack(enemy, target) do
      
      # The attack
      attack = 0
      target.active_spaceship.update_columns(hp: target.active_spaceship.hp - attack.round)
      
      # If target hp is below 0 -> die
      if target.active_spaceship.hp <= 0
        target.active_spaceship.update_columns(hp: 0)
        target.die and return
      end
      
      # Tell player to update their hp
      ActionCable.server.broadcast("player_#{target.id}", method: 'update_health', hp: target.active_spaceship.hp)
      
      # Global Cooldown
      sleep(2)
    end
    # If target is gone wait for new to pop up
    wait_for_new_target(enemy)
  end
end