class EnemyWorker < ApplicationWorker
  # This worker simulates an enemy

  def perform(npc, location, target = nil, attack = nil, count = nil, hard = nil)
    # Set some vars
    @location = Location.ensure(location)
    return unless @location

    # FIXME: really should remove this "global" state
    @enemy = Npc.ensure(npc)
    @target = User.ensure(target)
    @attack = attack
    @count = count
    @hard = hard

    if (@enemy.nil? || @enemy.npc_state == nil) && @attack.nil?
      if @location.mission && @location.mission.vip? && @count
        if (@count == 1) && (@location.mission.enemy_amount == 3)
          @enemy = Npc.create(npc_type: :politician, location: @location, hp: 150, name: Npc.random_name)
        else
          @enemy = Npc.create(npc_type: :bodyguard, location: @location, hp: 75, name: Npc.random_name)
        end
      elsif @location.system.wormhole?
        @enemy = Npc.create(npc_type: :enemy, location: @location, hp: 1250, name: Npc.random_name)
      elsif (@location.exploration_site? && (@location.enemy_amount == 1)) || @hard
        @enemy = Npc.create(npc_type: :wanted_enemy, location: @location, hp: 650, name: Npc.random_name)
      else
        @enemy = Npc.create(npc_type: :enemy, location: @location, hp: [50, 75, 100].sample, name: Npc.random_name)
      end

      @enemy.created!
      @enemy.location.broadcast(:player_appeared)
      EnemyWorker.perform_in(3.second, @enemy.id, @location.id) && (return)
    end

    # Find random User in location and target
    @target ||= @location.users.where(docked: false).is_online.sample

    if @target && can_attack?(@enemy, @target)
      attack()
    else
      wait_for_new_target(@enemy)
    end
  end

  # ################
  # NPC can attack?
  # ################
  def can_attack?(enemy, target)
    if enemy && target
      enemy.reload
      target.reload

      target.can_be_attacked && (target.location == enemy.location) && (enemy.hp > 0) && (target.active_spaceship.hp > 0)
    else
      false
    end
  end

  # ################
  # Wait for new target
  # ################
  def wait_for_new_target(enemy)
    return if enemy&.reload&.hp.to_i.zero?

    if enemy.reload.waiting?
      # Find first User in system and target
      target = enemy.location.users.where(docked: false).is_online.sample

      if target && can_attack?(enemy, target)
        enemy.created!
        attack
      else
        enemy.destroy
        return
      end
    else
      enemy.waiting!
      EnemyWorker.perform_in(10.second, @enemy.id, @location.id)
    end
  end

  # ################
  # Attack
  # ################
  def attack
    target_spaceship = @target.active_spaceship

    if @enemy.reload.created?
      # Sets user as target of npc
      @enemy.update(target: @target.id)

      # Tell user he is getting targeted by outlaw
      @target.broadcast(:getting_targeted, name: @enemy.name)

      # Set Enemy State to targeting
      @enemy.targeting!

      EnemyWorker.perform_in(3.second, @enemy.id, @location.id, @target.id) && (return)

    elsif @enemy.targeting?
      # Tell user he is getting attacked by outlaw
      @target.broadcast(:getting_attacked, name: @enemy.name)

      # Create attack value
      if @location.mission && @location.mission.difficulty
        case @location.mission.difficulty
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
    if can_attack?(@enemy, @target) && @attack

      # The attack
      target_spaceship.decrement!(:hp, @attack.round)

      # Tell player to update their hp and log
      @target.broadcast(:update_health, hp: target_spaceship.reload.hp)
      @target.broadcast(:log, text: I18n.t('log.you_got_hit_hp', attacker: @enemy.name, hp: @attack.round))

      if @target.fleet
        ChatChannel.broadcast_to(@target.fleet.chat_room, method: 'update_hp_color', color: @target.active_spaceship.get_hp_color, id: @target.id)
      end

      # If target hp is below 0 -> die
      if target_spaceship.hp <= 0
        target_spaceship.update(hp: 0)
        # Remove user from being targeted by others
        @target.remove_being_targeted
        @target.die
        wait_for_new_target(@enemy)
      end

      # Global Cooldown
      EnemyWorker.perform_in(2.second, @enemy.id, @location.id, @target.id, @attack) && (return) if @enemy && @target
    end

    # If target is gone wait for new to pop up
    @enemy&.reload
    wait_for_new_target(@enemy)
  end
end
