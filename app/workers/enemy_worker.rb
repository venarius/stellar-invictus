class EnemyWorker
  # This worker simulates an enemy

  include Sidekiq::Worker
  sidekiq_options retry: false

  @location
  @enemy
  @target
  @attack

  def perform(npc_id, location_id, target_id = nil, attack = nil, count = nil, hard = nil)

    # Set some vars
    @location = Location.find(location_id) rescue nil
    @enemy = Npc.find(npc_id) rescue nil if npc_id
    @target = User.find(target_id) rescue nil if target_id
    @attack = attack
    @count = count
    @hard = hard

    return unless @location

    if (@enemy.nil? || @enemy.npc_state == nil) && @attack.nil?
      if @location.mission && @location.mission.vip? && @count
        if (@count == 1) && (@location.mission.enemy_amount == 3)
          @enemy = Npc.create(npc_type: 'politician', location: @location, hp: 150, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
        else
          @enemy = Npc.create(npc_type: 'bodyguard', location: @location, hp: 75, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
        end
      elsif @location.system.wormhole?
        @enemy = Npc.create(npc_type: 'enemy', location: @location, hp: 1250, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
      elsif (@location.exploration_site? && (@location.enemy_amount == 1)) || @hard
        @enemy = Npc.create(npc_type: 'wanted_enemy', location: @location, hp: 650, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
      else
        @enemy = Npc.create(npc_type: 'enemy', location: @location, hp: [50, 75, 100].sample, name: "#{Faker::Name.first_name} #{Faker::Name.last_name}")
      end

      @enemy.created!
      ActionCable.server.broadcast("location_#{@enemy.location.id}", method: 'player_appeared')
      EnemyWorker.perform_in(3.second, @enemy.id, @location.id) && (return)
    end

    # Find first User in location and target
    unless @target
      @target = User.where(location: @location, docked: false).where('online > 0').sample rescue nil
    end

    if @target && can_attack
      attack()
    else
      wait_for_new_target if @enemy && (@enemy.hp > 0)
    end
  end

  # ################
  # NPC can attack?
  # ################
  def can_attack
    @enemy = @enemy.reload rescue nil
    @target = @target.reload rescue nil

    if @enemy && @target
      @target.can_be_attacked && (@target.location == @enemy.location) && (@enemy.hp > 0) && (@target.reload.active_spaceship.hp > 0)
    else
      false
    end
  end

  # ################
  # Wait for new target
  # ################
  def wait_for_new_target
    if @enemy.reload.waiting?
      # Find first User in system and target
      @target = User.where(location: @enemy.location, docked: false).where('online > 0').sample rescue nil

      if @target && can_attack
        @enemy.created!
        attack
      else
        @enemy.destroy && (return)
      end
    else
      @enemy.waiting!
      EnemyWorker.perform_in(10.second, @enemy.id, @location.id) && (return)
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

      EnemyWorker.perform_in(3.second, @enemy.id, @location.id, @target.id) && (return)

    elsif @enemy.targeting?

      # Tell user he is getting attacked by outlaw
      ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: @enemy.name)

      # Create attack value
      if @location.mission && @location.mission_difficulty
        case @location.mission_difficulty
        when 'easy'
          @attack = rand(2..5) * (1.0 - target_spaceship.get_defense / 100.0)
        when 'medium'
          @attack = rand(15..20) * (1.0 - target_spaceship.get_defense / 100.0)
        when 'hard'
          @attack = rand(25..30) * (1.0 - target_spaceship.get_defense / 100.0)
        end
      elsif @location.system.wormhole?
        @attack = rand(100..150) * (1.0 - target_spaceship.get_defense / 100.0)
      elsif (@location.exploration_site? && (@location.enemy_amount == 1)) || @enemy.wanted_enemy?
        @attack = rand(40..50) * (1.0 - target_spaceship.get_defense / 100.0)
      else
        @attack = rand(2..5) * (1.0 - target_spaceship.get_defense / 100.0)
      end

      @enemy.attacking!

    end

    # If npc can attack player
    if can_attack && @attack

      # The attack
      target_spaceship.update_columns(hp: target_spaceship.reload.hp - @attack.round)

      # Tell player to update their hp and log
      ac_server.broadcast("player_#{target_id}", method: 'update_health', hp: target_spaceship.hp)
      ac_server.broadcast("player_#{target_id}", method: 'log', text: I18n.t('log.you_got_hit_hp', attacker: @enemy.name, hp: @attack.round))

      if @target.fleet
        ChatChannel.broadcast_to(@target.fleet.chat_room, method: 'update_hp_color', color: @target.active_spaceship.get_hp_color, id: @target.id)
      end

      # If target hp is below 0 -> die
      if target_spaceship.hp <= 0
        target_spaceship.update_columns(hp: 0)
        # Remove user from being targeted by others
        @target.remove_being_targeted
        @target.die
        wait_for_new_target if (@enemy.reload.hp rescue 0) > 0
      end

      # Global Cooldown
      EnemyWorker.perform_in(2.second, @enemy.id, @location.id, @target.id, @attack) && (return) if @enemy && @target
    end

    # If target is gone wait for new to pop up
    @enemy = @enemy.reload rescue nil
    wait_for_new_target if @enemy && (@enemy.hp > 0)
  end
end
