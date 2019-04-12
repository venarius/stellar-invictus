class MissionGenerator

  # Generate Mission
  def self.generate_missions(location_id)
    location = Location.ensure(location_id)
    return unless location

    offered_mission_count = location.missions.offered.count
    if (offered_mission_count < 6)
      (6 - offered_mission_count).times do
        generate_mission(location)
      end
    end
  end

  # Finish Mission
  def self.finish_mission(mission_id)
    mission = Mission.ensure(mission_id)
    return nil unless mission

    # check location
    if (mission.location != mission.user.location) && !mission.delivery?
      return I18n.t('errors.this_agent_is_not_on_this_station')
    end

    case mission.mission_type
    when 'delivery'
      # check location
      return I18n.t('errors.this_isnt_the_right_station') if mission.deliver_to != mission.user.location.id

      # check amount
      item = Item.where(user: mission.user, location: mission.deliver_location, loader: mission.mission_loader).first
      if !item || item.count < mission.mission_amount
        return I18n.t('errors.you_dont_have_the_required_amount_in_storage')
      end

      # remove items
      Item::RemoveFromUser.(user: mission.user, location: mission.deliver_location, loader: mission.mission_loader, amount: mission.mission_amount)
    when 'combat', 'vip'
      # check enemy_amound
      return I18n.t('errors.you_didnt_kill_all_enemies') if mission.enemy_amount > 0

      # check if user is onsite
      if mission.mission_location.users.count > 0 || Spaceship.where(warp_target_id: mission.mission_location.id).present?
        return I18n.t('errors.mission_location_not_cleared')
      end
    when 'market'
      # check amount
      item = Item.where(user: mission.user, location: mission.location, loader: mission.mission_loader).first
        if !item || item.count < mission.mission_amount
          return I18n.t('errors.you_dont_have_the_required_amount_in_storage')
        end

      # remove items
      Item::RemoveFromUser.(user: mission.user, location: mission.location, loader: mission.mission_loader, amount: mission.mission_amount)
    when 'mining'
      # check amount
      return I18n.t('errors.you_didnt_mine_enough_ore') if mission.mission_amount > 0
    end

    mission.user.give_units(mission.reward)

    if mission.vip? && mission.mission_location.faction
      mission.user.increment!("reputation_#{mission.faction_id}", mission.faction_bonus)
      mission.user.decrement!("reputation_#{mission.mission_location.faction_id}", mission.faction_malus)
    else
      params = {
        reputation_1: mission.user.reputation_1 - mission.faction_malus,
        reputation_2: mission.user.reputation_2 - mission.faction_malus,
        reputation_3: mission.user.reputation_3 - mission.faction_malus
      }
      params["reputation_#{mission.faction_id}".to_sym] += mission.faction_malus + mission.faction_bonus
      mission.user.update(params)
    end

    mission.destroy
    nil
  end

  # Generate Mission Sub
  def self.generate_mission(location)
    mission = Mission.new(location: location, mission_status: :offered)

    difficulty = rand(3)

    if rand(1) == 1
      mission.agent_name = "#{Faker::Name.male_first_name} #{Faker::Name.last_name}"
      mission.agent_avatar = "M_#{rand(1..17)}"
    else
      mission.agent_name = "#{Faker::Name.female_first_name} #{Faker::Name.last_name}"
      mission.agent_avatar = "F_#{rand(1..15)}"
    end

    mission.text = rand(1..3)

    if location.faction == nil
      mission.faction_id = rand(1..3)
      mission.mission_type = [:delivery, :combat, :mining, :market].sample
    else
      mission.faction_id = location.faction_id
      mission.mission_type = [:delivery, :combat, :mining, :market, :vip].sample
    end

    if mission.delivery?
      # Get System to Deliver To
      station_ids = Location.station.ids
      loop do
        mission.deliver_to = station_ids.sample
        break if mission.deliver_to != location.id
      end

      # Set Difficulty based on Path
      path = Pathfinder.find_path(location.system.id, mission.deliver_location.system.id)
      case
      when path.size > 10 then difficulty = 2
      when path.size > 5  then difficulty = 1
      when path.size >= 0 then difficulty = 0
      end

      # Set Reward
      mission.reward = (20 * path.size * rand(0.8..1.2)).round
      mission.reward = mission.reward * 3 if mission.deliver_location.system.low?

      # Generate Items
      mission.mission_loader = Item::DELIVERY.sample
      mission.mission_amount = rand(2..5)

    elsif mission.combat?
      mission.enemy_amount = rand(2..5) * (difficulty + 1)
      system = location.system
      jumpgate = system.locations.jumpgate.random_row
      mission_system = System.ensure(jumpgate.name)
      mission.mission_location = Location.create(location_type: :mission, system: mission_system)

      # Set Reward
      mission.reward = (40 * (difficulty + 1) * mission.enemy_amount * rand(0.8..1.2)).round
      mission.reward = mission.reward * 3 if mission.mission_location.system.low?

    elsif mission.mining? || mission.market?
      if mission.market?
        mission.mission_loader = Item::EQUIPMENT_EASY.sample
      else
        mission.mission_loader = (Item::ASTEROIDS - ['asteroid.tryon_ore', 'asteroid.lunarium_ore']).sample
      end
      mission.mission_amount = ((difficulty + 1) * rand(5..10))

      # Set Reward
      mission.reward = (Item.get_attribute(mission.mission_loader, :price) * mission.mission_amount * rand(1.05..1.10)).round

    elsif mission.vip?
      mission.enemy_amount = 3
      m_location = Location.where.not(faction_id: [mission.faction_id, nil]).random_row
      mission.mission_location = Location.create(location_type: :mission, system: m_location.system, faction: m_location.faction)

      # Set Reward
      mission.reward = (400 * rand(0.8..1.2)).round
      mission.reward = mission.reward * 3 if mission.mission_location.system.low?

      # Set Difficulty
      difficulty = 1

      # Set Bonus / Malus
      mission.faction_bonus = 0.25
      mission.faction_malus = 0.25
    end

    mission.faction_bonus = (0.05 * (difficulty + 1)) unless mission.faction_bonus
    mission.faction_malus = (0.05 * rand(0..1)) unless mission.faction_malus

    mission.difficulty = difficulty

    if !mission.save
      Rails.logger.info "!!BAD MISSION: #{mission.errors.full_messages}"
    end

    mission
  end

  # Abort Mission
  def self.abort_mission(mission_id)
    mission = Mission.ensure(mission_id)

    case mission.mission_type
    when 'delivery'
      Item.where(mission: mission).destroy_all
    when 'combat'
      # check if user is onsite
      if mission.mission_location.users.count > 0 || Spaceship.where(warp_target: mission.mission_location).present?
        return I18n.t('errors.mission_location_not_cleared')
      end
    end

    # Reduce Reputation
    mission.user.update_attribute("reputation_#{mission.faction_id}", mission.user["reputation_#{mission.faction_id}"] - 0.2)

    mission.destroy
    nil
  end
end
