class EnemyWorker < ApplicationWorker
  # This worker simulates an enemy

  def perform(npc_id, location_id, target_id = nil, attack = nil, count = nil, hard = nil)
    debug_args(npc: npc_id, location: location_id, target: target_id, attack: attack, count: count, hard: hard)

    # Set some vars
    location = Location.ensure(location_id)
    return unless location
    enemy = Npc.ensure(npc_id)
    target = User.ensure(target_id)

    if (enemy.nil? || enemy.npc_state == nil) && attack.to_i.zero?
      if location.mission && location.mission.vip? && count
        if (count == 1) && (@location.mission.enemy_amount == 3)
          enemy = Npc.create(npc_type: :politician, location: location, hp: 150)
        else
          enemy = Npc.create(npc_type: :bodyguard, location: location, hp: 75)
        end
      elsif location.system.wormhole?
        enemy = Npc.create(npc_type: :enemy, location: location, hp: 1250)
      elsif (location.exploration_site? && (location.enemy_amount == 1)) || hard
        enemy = Npc.create(npc_type: :wanted_enemy, location: location, hp: 650)
      else
        enemy = Npc.create(npc_type: :enemy, location: location, hp: [50, 75, 100].sample)
      end
      # ap "Enemy(#{enemy.npc_type}) created!"
      enemy.created!
      enemy.location.broadcast(:player_appeared)
      EnemyWorker.perform_in(3.second, enemy.id, location.id)
      return
    end

    # Find random User in location and target
    target ||= location.random_online_in_space_user
    if target && can_attack?(enemy, target)
      handle_attack(enemy, target)
    else
      wait_for_new_target(enemy)
    end
  end

  # ################
  # NPC can attack?
  # ################
  def can_attack?(enemy, target)
    if enemy && target
      enemy.reload
      target.reload

      target.can_be_attacked? &&
        (target.location_id == enemy.location_id) &&
        (enemy.hp > 0) &&
        (target.ship.hp > 0)
    else
      false
    end
  end

  # ################
  # Wait for new target
  # ################
  def wait_for_new_target(enemy)
    return unless enemy
    enemy.reload
    return if enemy.hp.to_i.zero?

    if enemy.waiting?
      # Find first User in system and target
      target = enemy.location.random_online_in_space_user

      if target && can_attack?(enemy, target)
        enemy.created!
        handle_attack(enemy, target)
      else
        enemy.destroy
        return
      end
    else
      enemy.waiting!
      EnemyWorker.perform_in(10.second, enemy.id, enemy.location.id)
    end
  end

  # ################
  # Attack
  # ################
  def handle_attack(enemy, target)
    enemy&.reload
    if enemy.created?
      # Sets user as target of npc
      enemy.update(target: target)

      # Tell user he is getting targeted by outlaw
      target.broadcast(:getting_targeted, name: enemy.name)

      # Set Enemy State to targeting
      enemy.targeting!

      EnemyWorker.perform_in(3.second, enemy.id, enemy.location.id, target.id)
      return

    elsif enemy.targeting?
      # Tell user he is getting attacked by outlaw
      target.broadcast(:getting_attacked, name: enemy.name)
      location = target.location
      # Create attack value
      if location.mission && location.mission.difficulty
        case location.mission.difficulty
        when 'easy'
          attack = rand(2..5) * (1.0 - target.ship.get_defense / 100.0)
        when 'medium'
          attack = rand(15..20) * (1.0 - target.ship.get_defense / 100.0)
        when 'hard'
          attack = rand(25..30) * (1.0 - target.ship.get_defense / 100.0)
        end
      elsif location.system.wormhole?
        attack = rand(100..150) * (1.0 - target.ship.get_defense / 100.0)
      elsif (location.exploration_site? && (location.enemy_amount == 1)) || enemy.wanted_enemy?
        attack = rand(40..50) * (1.0 - target.ship.get_defense / 100.0)
      else
        attack = rand(2..5) * (1.0 - target.ship.get_defense / 100.0)
      end

      enemy.attacking!
    end

    # If npc can attack player
    if can_attack?(enemy, target) && attack

      # The attack
      target.ship.decrement!(:hp, attack.round)

      # Tell player to update their hp and log
      target.broadcast(:update_health, hp: target.ship.reload.hp)
      target.broadcast(:log, text: I18n.t('log.you_got_hit_hp', attacker: enemy.name, hp: attack.round))

      if target.fleet
        ChatChannel.broadcast_to(target.fleet.chat_room, method: 'update_hp_color', color: target.ship.get_hp_color, id: target.id)
      end

      # If target hp is below 0 -> die
      if target.ship.hp <= 0
        target.ship.update(hp: 0)
        # Remove user from being targeted by others
        target.remove_being_targeted
        target.die
        wait_for_new_target(enemy)
      end

      # Global Cooldown
      if enemy && target
        EnemyWorker.perform_in(2.second, enemy.id, enemy.location.id, target.id, attack)
        return
      end
    end

    # If target is gone wait for new to pop up
    wait_for_new_target(enemy)
  end
end
