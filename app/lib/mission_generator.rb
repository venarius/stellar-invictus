class MissionGenerator
  
  # Generate Mission
  def self.generate_missions(user_id)
    user = User.find(user_id) rescue nil
    if user and user.missions.count < 6
      
      (6 - user.missions.count).times do
        generate_mission(user)
      end
      
    end
  end
  
  # Finish Mission
  def self.finish_mission(mission_id)
    mission = Mission.find(mission_id)
    
    case mission.mission_type
      when 'delivery'
        # check location
        return I18n.t('errors.this_isnt_the_right_station') if mission.deliver_to != mission.user.location.id
        
         # check amount
        amount = mission.user.location.get_items(mission.user.id)[mission.mission_loader] rescue nil
        if !amount || amount < mission.mission_amount
          return I18n.t('errors.you_dont_have_the_required_amount_in_storage') 
        end
        
        # remove items
        Item.where(user: mission.user, location: mission.user.location, loader: mission.mission_loader).limit(mission.mission_amount).destroy_all
      when 'combat'
        # check enemy_amound
        return I18n.t('errors.you_didnt_kill_all_enemies') if mission.enemy_amount > 0
        
        # check if user is onsite
        return I18n.t('errors.mission_location_not_cleared') if mission.location.users.count > 0
      when 'market'
        # check amount
        amount = mission.user.location.get_items(mission.user.id)[mission.mission_loader] rescue nil
        if !amount || amount < mission.mission_amount
          return I18n.t('errors.you_dont_have_the_required_amount_in_storage') 
        end
        
        # remove items
        Item.where(user: mission.user, location: mission.user.location, loader: mission.mission_loader).limit(mission.mission_amount).destroy_all
      when 'mining'
        # check amount
        return I18n.t('errors.you_didnt_mine_enough_ore') if mission.mission_amount > 0
    end
    
    mission.user.update_columns(units: mission.user.units + mission.reward)
        
    mission.destroy and return nil
  end
  
  # Generate Mission Sub
  def self.generate_mission(user)
    
    mission = Mission.new
    
    mission.user = user
    
    difficulty = rand(2)
    
    mission.mission_type = rand(1..4)
    
    mission.mission_status = 'offered'
    
    if rand(1) == 1
      mission.agent_name = "#{Faker::Name.male_first_name} #{Faker::Name.last_name}"
      mission.agent_avatar = "M_#{rand(1..17)}"
    else
      mission.agent_name = "#{Faker::Name.female_first_name} #{Faker::Name.last_name}"
      mission.agent_avatar = "F_#{rand(1..15)}"
    end
    
    mission.text = rand(1..3)
    
    mission.faction_id = rand(1..3)
    
    if mission.mission_type == 'delivery'
      
      # Get System to Deliver To
      loop do
        mission.deliver_to = Location.reload.where(location_type: 'station').order(Arel.sql("RANDOM()")).limit(1).pluck(:id)[0]
        break if mission.deliver_to != user.location.id
      end
      
      # Set Difficulty based on Path
      path = Pathfinder.find_path(user.system.id, Location.find(mission.deliver_to).system.id)
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
      
      # Generate Items
      loader = ITEMS.sample
      mission.mission_loader = loader
      amount = rand(2..5)
      amount.times do
        mission.items << Item.create(loader: loader, user: user)
      end
      mission.mission_amount = amount
    elsif mission.mission_type == 'combat'
      mission.enemy_amount = rand(2..5) * (difficulty + 1)
      mission.location = Location.create(location_type: 'mission', system_id: System.where.not(security_status: 'low').order(Arel.sql("RANDOM()")).limit(1).pluck(:id)[0], name: 'Enemy Hive')
      
      # Set Reward
      mission.reward = (10 * mission.enemy_amount * rand(0.8..1.2)).round
    elsif mission.mission_type == 'mining' || mission.mission_type == 'market'
      if mission.mission_type == 'market'
        mission.mission_loader = ITEMS.sample
      else
        mission.mission_loader = ASTEROIDS.sample
      end
      mission.mission_amount = ((difficulty + 1) * rand(5..10))
      
      # Set Reward
      mission.reward = (get_item_attribute(mission.mission_loader, 'price') * mission.mission_amount * rand(0.8..1.2)).round
    end
    
    mission.faction_bonus = (0.1 * (difficulty + 1))
    
    mission.faction_malus = (0.1 * rand(0..1))
    
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
end