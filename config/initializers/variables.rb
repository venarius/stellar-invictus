begin

    SHIP_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/spaceships.yml") unless defined? SHIP_VARIABLES
    ITEM_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/items.yml") unless defined? ITEM_VARIABLES
    STATION_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/stations.yml") unless defined? STATION_VARIABLES
    FACTION_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/factions.yml") unless defined? FACTION_VARIABLES
    RIDDLE_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/riddles.yml") unless defined? RIDDLE_VARIABLES
    PATHFINDER = YAML.load_file("#{Rails.root.to_s}/config/variables/pathfinder.yml") unless defined? PATHFINDER
    
    # Equipment
    EQUIPMENT = ["equipment.weapons.laser_gatling", "equipment.weapons.try_pyon_laser",
                "equipment.miner.advanced_miner", "equipment.miner.basic_miner", 
                "equipment.storage.small_black_hole", "equipment.defense.ion_shield",
                "equipment.defense.try_pyon_shield", "equipment.warp_core_stabilizers.warp_core_stabilizer",
                "equipment.hulls.light_hull", "equipment.sensors.small_sensor", 
                "equipment.repair_bots.simple_repair_bot", "equipment.warp_disruptors.basic_warp_disruptor",
                "equipment.scanner.basic_scanner", "equipment.scanner.advanced_scanner", "equipment.scanner.military_scanner"] unless defined? EQUIPMENT
                
    # Materials
    MATERIALS = ["materials.sensor_electronics", "materials.antimatter", "materials.fusion_electronics",
                "materials.ai_components", "materials.metal_plates", "materials.laser_diodes"] unless defined? MATERIALS
                
    # Asteroids
    ASTEROIDS = ["asteroid.nickel", "asteroid.septarium", "asteroid.cobalt", "asteroid.iron"] unless defined? ASTEROIDS
                
    # Items
    ITEMS = EQUIPMENT + MATERIALS + ASTEROIDS unless defined? ITEMS
  
rescue StandardError
  true
end