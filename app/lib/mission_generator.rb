class MissionGenerator
  
  # Generate Mission
  def self.generate_missions(location_id)
    location = Location.find(location_id) rescue nil
    if location and location.missions.where(mission_status: 'offered').count < 6
      
      (6 - location.missions.where(mission_status: 'offered').count).times do
        generate_mission(location)
      end
      
    end
  end
  
  # Finish Mission
  def self.finish_mission(mission_id)
    mission = Mission.find(mission_id)
    
    # check location
    return I18n.t('errors.this_agent_is_not_on_this_station') if mission.location != mission.user.location and mission.mission_type != 'delivery'
    
    case mission.mission_type
      when 'delivery'
        # check location
        return I18n.t('errors.this_isnt_the_right_station') if mission.deliver_to != mission.user.location.id
        
         # check amount
        amount = Location.find(mission.deliver_to).get_items(mission.user.id)[mission.mission_loader] rescue nil
        if !amount || amount < mission.mission_amount
          return I18n.t('errors.you_dont_have_the_required_amount_in_storage') 
        end
        
        # remove items
        Item.where(user: mission.user, location: mission.mission_location, loader: mission.mission_loader).limit(mission.mission_amount).destroy_all
      when 'combat', 'vip'
        # check enemy_amound
        return I18n.t('errors.you_didnt_kill_all_enemies') if mission.enemy_amount > 0
        
        # check if user is onsite
        return I18n.t('errors.mission_location_not_cleared') if mission.mission_location.users.count > 0
      when 'market'
        # check amount
        amount = mission.location.get_items(mission.user.id)[mission.mission_loader] rescue nil
        if !amount || amount < mission.mission_amount
          return I18n.t('errors.you_dont_have_the_required_amount_in_storage') 
        end
        
        # remove items
        Item.where(user: mission.user, location: mission.location, loader: mission.mission_loader).limit(mission.mission_amount).destroy_all
      when 'mining'
        # check amount
        return I18n.t('errors.you_didnt_mine_enough_ore') if mission.mission_amount > 0
    end
    
    mission.user.give_units(mission.reward)
    
    if mission.vip? and mission.mission_location.faction
      mission.user.update_attribute("reputation_#{mission.faction_id}", mission.user["reputation_#{mission.faction_id}"] + mission.faction_bonus)
      mission.user.update_attribute("reputation_#{mission.mission_location.faction_id}", mission.user["reputation_#{mission.mission_location.faction_id}"] - mission.faction_malus)
    else
      case mission.faction_id
        when 1
          mission.user.update_columns(reputation_1: mission.user_reputation_1 + mission.faction_bonus, reputation_2: mission.user_reputation_2 - mission.faction_malus, reputation_3: mission.user_reputation_3 - mission.faction_malus)
        when 2
          mission.user.update_columns(reputation_1: mission.user_reputation_1 - mission.faction_malus, reputation_2: mission.user_reputation_2 + mission.faction_bonus, reputation_3: mission.user_reputation_3 - mission.faction_malus)
        when 3
          mission.user.update_columns(reputation_1: mission.user_reputation_1 - mission.faction_malus, reputation_2: mission.user_reputation_2 - mission.faction_malus, reputation_3: mission.user_reputation_3 + mission.faction_bonus)
      end
    end
        
    mission.destroy and return nil
  end
  
  # Generate Mission Sub
  def self.generate_mission(location)
    
    mission = Mission.new
    
    mission.location = location
    
    difficulty = rand(2)
    
    mission.mission_status = 'offered'
    
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
      mission.mission_type = rand(1..4)
    else
      mission.faction_id = location.faction_id
      mission.mission_type = rand(1..5)
    end
    
    if mission.mission_type == 'delivery'
      
      # Get System to Deliver To
      loop do
        mission.deliver_to = Location.uncached do Location.where(location_type: 'station').order(Arel.sql("RANDOM()")).limit(1).pluck(:id)[0] end
        break if mission.deliver_to != location.id
      end
      
      # Set Difficulty based on Path
      path = Pathfinder.find_path(location.system.id, Location.find(mission.deliver_to).system.id)
      case 
        when path.size > 10
          difficulty = 2
        when path.size > 5
          difficulty = 1
        when path.size >= 0
          difficulty = 0
      end
      
      # Set Reward
      mission.reward = (10 * path.size * rand(0.8..1.2)).round
      mission.reward = mission.reward * 3 if Location.find(mission.deliver_to).system_security_status == 'low'
      
      # Generate Items
      loader = ITEMS.sample
      mission.mission_loader = loader
      amount = rand(2..5)
      amount.times do
        mission.items << Item.create(loader: loader)
      end
      mission.mission_amount = amount
    elsif mission.mission_type == 'combat'
      mission.enemy_amount = rand(2..5) * (difficulty + 1)
      mission.mission_location = Location.create(location_type: 'mission', system_id: System.find_by(name: location.system.locations.where(location_type: 'jumpgate').order(Arel.sql("RANDOM()")).first.name).id)
      
      # Set Reward
      mission.reward = (10 * mission.enemy_amount * rand(0.8..1.2)).round
      mission.reward = mission.reward * 3 if mission.mission_location.system.security_status == 'low'
    elsif mission.mission_type == 'mining' || mission.mission_type == 'market'
      if mission.mission_type == 'market'
        mission.mission_loader = ITEMS.sample
      else
        mission.mission_loader = ASTEROIDS.sample
      end
      mission.mission_amount = ((difficulty + 1) * rand(5..10))
      
      # Set Reward
      mission.reward = (get_item_attribute(mission.mission_loader, 'price') * mission.mission_amount * rand(1.0..1.2)).round
    elsif mission.mission_type == 'vip'
      mission.enemy_amount = 3
      m_location = Location.where.not(faction_id: mission.faction_id).where("faction_id IS NOT NULL").first
      mission.mission_location = Location.create(location_type: 'mission', system_id: m_location.system.id, faction_id: m_location.faction_id)
      
       # Set Reward
      mission.reward = (100 * rand(0.8..1.2)).round
      mission.reward = mission.reward * 3 if mission.mission_location.system.security_status == 'low'
      
      # Set Difficulty
      difficulty = 1
      
      # Set Bonus / Malus
      mission.faction_bonus = 1
      mission.faction_malus = 1
    end
    
    mission.faction_bonus = (0.1 * (difficulty + 1)) unless mission.faction_bonus
    
    mission.faction_malus = (0.1 * rand(0..1)) unless mission.faction_malus
    
    mission.difficulty = difficulty
    
    if !mission.save
      Rails.logger.info mission.errors.full_messages
    end
    
  end
  
  def self.get_item_attribute(loader, attribute)
    atty = loader.split(".")
    out = ITEM_VARIABLES[atty[0]]
    loader.count('.').times do |i|
      out = out[atty[i+1]]
    end
    out[attribute] rescue nil
  end
  
  # Abort Mission
  def self.abort_mission(mission_id)
    mission = Mission.find(mission_id)
    
    case mission.mission_type
      when 'delivery'
        mission.items.delete_all
      when 'combat'
        # check if user is onsite
        return I18n.t('errors.mission_location_not_cleared') if mission.mission_location.users.count > 0 || Spaceship.where(warp_target_id: mission.location.id).present?
    end
    
    # Reduce Reputation
    mission.user.update_attribute("reputation_#{mission.faction_id}", mission.user["reputation_#{mission.faction_id}"] - 1)
    
    mission.destroy and return nil
  end
end