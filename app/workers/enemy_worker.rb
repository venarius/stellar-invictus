class EnemyWorker
  # This worker simulates an enemy
  
  include Sidekiq::Worker
  sidekiq_options :retry => false
  
  @location
  @enemy
  @target
  @attack

  def perform(npc_id, location_id, target_id=nil, attack=nil, count=nil)
    
    # Set some vars
    @location = Location.find(location_id)
    @enemy = Npc.find(npc_id) rescue nil if npc_id
    @target = User.find(target_id) rescue nil if target_id
    @attack = attack
    @count = count
    
    if (@enemy.nil? || @enemy.npc_state == nil) and @attack.nil?
      if @location.mission and @location.mission.vip? and @count
        if @count == 1
          @enemy = Npc.create(npc_type: 'politician', location: @location, hp: 100, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
        else
          @enemy = Npc.create(npc_type: 'bodyguard', location: @location, hp: 50, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
        end
      elsif @location.exploration_site? and @location.enemy_amount == 1
        @enemy = Npc.create(npc_type: 'wanted_enemy', location: @location, hp: 450, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
      else
        @enemy = Npc.create(npc_type: 'enemy', location: @location, hp: 50, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
      end
      
      @enemy.created!
      ActionCable.server.broadcast("location_#{@enemy.location.id}", method: 'player_appeared')
      EnemyWorker.perform_in(3.second, @enemy.id, @location.id) and return
    end
    
    # Find first User in location and target
    unless @target
      @target = User.where(location: @location, docked: false).where('online > 0').sample rescue nil
    end
    
    if @target and can_attack
      attack()
    else
      wait_for_new_target if @enemy and @enemy.hp > 0
    end
  end
  
  # ################
  # NPC can attack?
  # ################
  def can_attack
    @enemy = @enemy.reload rescue nil
    @target = @target.reload rescue nil
    
    if @enemy and @target
      @target.can_be_attacked and @target.location == @enemy.location and @enemy.hp > 0
    else
      false
    end
  end
  
  # ################
  # Wait for new target
  # ################
  def wait_for_new_target
    if @enemy.waiting? == false
      @enemy.waiting!
      EnemyWorker.perform_in(10.second, @enemy.id, @location.id) and return
    else
      # Find first User in system and target
      @target = User.where(location: @enemy.location, docked: false).where('online > 0').sample rescue nil
      
      if @target.present?
        attack
      else
        @enemy.destroy and return
      end
    end
  end
  
  # ################
  # Attack
  # ################
  def attack
    # Gets target id and spaceship
    target_id = @target.id
    target_spaceship = @target.active_spaceship
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    if @enemy.reload.created?
    
      # Sets user as target of npc
      @enemy.update_columns(target: target_id)
        
      # Tell user he is getting targeted by outlaw
      ac_server.broadcast("player_#{target_id}", method: 'getting_targeted', name: @enemy.name)
      
      # Set Enemy State to targeting
      @enemy.targeting!
      
      EnemyWorker.perform_in(3.second, @enemy.id, @location.id, @target.id) and return
      
    elsif @enemy.targeting?
    
      # Tell user he is getting attacked by outlaw
      ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: @enemy.name)
      
      # Create attack value
      if @location.mission and @location.mission.difficulty
        case @location.mission.difficulty
          when 'easy'
            @attack = rand(2..5) * (1.0 - target_spaceship.get_defense/100.0)
          when 'medium'
            @attack = rand(5..10) * (1.0 - target_spaceship.get_defense/100.0)
          when 'hard'
            @attack = rand(10..15) * (1.0 - target_spaceship.get_defense/100.0)
        end
      elsif @location.exploration_site? and @location.enemy_amount == 1
        @attack = rand(20..30) * (1.0 - target_spaceship.get_defense/100.0)
      else
        @attack = rand(2..5) * (1.0 - target_spaceship.get_defense/100.0)
      end
      
      @enemy.attacking!
      
    end
    
    # While npc can attack player
    while can_attack and @attack do
      
      # The attack
      target_spaceship.update_columns(hp: target_spaceship.reload.hp - @attack.round)
      
      # Tell player to update their hp and log
      ac_server.broadcast("player_#{target_id}", method: 'update_health', hp: target_spaceship.hp)
      ac_server.broadcast("player_#{target_id}", method: 'log', text: I18n.t('log.you_got_hit_hp', attacker: @enemy.name, hp: @attack) )
      
      # If target hp is below 0 -> die
      if target_spaceship.hp <= 0
        target_spaceship.update_columns(hp: 0)
        @target.die
        wait_for_new_target if (@enemy.reload.hp rescue 0) > 0
      end
      
      # Global Cooldown
      EnemyWorker.perform_in(2.second, @enemy.id, @location.id, @target.id, @attack) and return
    end
    
    # If target is gone wait for new to pop up
    @enemy = @enemy.reload rescue nil
    wait_for_new_target if @enemy and @enemy.hp > 0
  end
end