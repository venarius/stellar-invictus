begin
    $allow_login = true

    SHIP_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/spaceships.yml") unless defined? SHIP_VARIABLES
    ITEM_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/items.yml") unless defined? ITEM_VARIABLES
    FACTION_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/factions.yml") unless defined? FACTION_VARIABLES
    RIDDLE_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/riddles.yml") unless defined? RIDDLE_VARIABLES
    PATHFINDER = YAML.load_file("#{Rails.root.to_s}/config/variables/pathfinder.yml") unless defined? PATHFINDER
    MAPDATA = YAML.load_file("#{Rails.root.to_s}/config/variables/mapdata.yml") unless defined? MAPDATA
    
    # Equipment
    EQUIPMENT = ["equipment.weapons.laser_gatling", "equipment.weapons.try_pyon_laser", "equipment.weapons.military_laser",
                 "equipment.hulls.light_hull", "equipment.hulls.ultralight_hull",
                 "equipment.sensors.small_sensor", "equipment.sensors.try_pyon_sensor",
                 "equipment.scanner.basic_scanner", "equipment.scanner.advanced_scanner", "equipment.scanner.military_scanner", "equipment.scanner.deepspace_scanner",
                 "equipment.warp_disruptors.basic_warp_disruptor", "equipment.warp_disruptors.try_pyon_warp_disruptor", "equipment.warp_disruptors.military_warp_disruptor",
                 "equipment.warp_core_stabilizers.basic_warp_core_stabilizer", "equipment.warp_core_stabilizers.try_pyon_warp_core_stabilizer", "equipment.warp_core_stabilizers.military_warp_core_stabilizer",
                 "equipment.miner.basic_miner", "equipment.miner.advanced_miner", "equipment.miner.core_miner",
                 "equipment.repair_bots.simple_repair_bot", "equipment.repair_bots.advanced_repair_bot", "equipment.repair_bots.colton_repair_bot",
                 "equipment.remote_repair.simple_repair_beam", "equipment.remote_repair.advanced_repair_beam", "equipment.remote_repair.colton_repair_beam",
                 "equipment.defense.ion_shield", "equipment.defense.try_pyon_shield",
                 "equipment.storage.small_black_hole", "equipment.storage.medium_black_hole", "equipment.storage.large_black_hole"] unless defined? EQUIPMENT
                 
    EQUIPMENT_EASY = ["equipment.weapons.laser_gatling",
                 "equipment.hulls.light_hull",
                 "equipment.sensors.small_sensor",
                 "equipment.scanner.basic_scanner",
                 "equipment.warp_disruptors.basic_warp_disruptor", 
                 "equipment.warp_core_stabilizers.basic_warp_core_stabilizer",
                 "equipment.miner.basic_miner",
                 "equipment.repair_bots.simple_repair_bot",
                 "equipment.remote_repair.simple_repair_beam",
                 "equipment.defense.ion_shield",
                 "equipment.storage.small_black_hole"] unless defined? EQUIPMENT_EASY
                 
    EQUIPMENT_MEDIUM = ["equipment.weapons.try_pyon_laser",
                 "equipment.scanner.advanced_scanner",
                 "equipment.warp_disruptors.try_pyon_warp_disruptor",
                 "equipment.warp_core_stabilizers.try_pyon_warp_core_stabilizer",
                 "equipment.miner.advanced_miner",
                 "equipment.repair_bots.advanced_repair_bot",
                 "equipment.remote_repair.advanced_repair_beam",
                 "equipment.storage.medium_black_hole"] unless defined? EQUIPMENT_MEDIUM
                 
    EQUIPMENT_HARD = ["equipment.weapons.military_laser",
                 "equipment.hulls.ultralight_hull",
                 "equipment.sensors.try_pyon_sensor",
                 "equipment.scanner.military_scanner",
                 "equipment.warp_disruptors.military_warp_disruptor",
                 "equipment.warp_core_stabilizers.military_warp_core_stabilizer",
                 "equipment.miner.core_miner",
                 "equipment.repair_bots.colton_repair_bot",
                 "equipment.remote_repair.colton_repair_beam",
                 "equipment.defense.try_pyon_shield",
                 "equipment.storage.large_black_hole"] unless defined? EQUIPMENT_HARD
                
    # Materials
    MATERIALS = ["materials.sensor_electronics", "materials.antimatter", "materials.fusion_electronics",
                "materials.ai_components", "materials.metal_plates", "materials.laser_diodes"] unless defined? MATERIALS
                
    # Asteroids
    ASTEROIDS = ["asteroid.nickel_ore", "asteroid.septarium_ore", "asteroid.cobalt_ore", "asteroid.iron_ore", "asteroid.titanium_ore", "asteroid.tryon_ore", "asteroid.lunarium_ore"] unless defined? ASTEROIDS
                
    # Items
    ITEMS = EQUIPMENT + MATERIALS + ASTEROIDS unless defined? ITEMS
    
    # Delivery
    DELIVERY = ["delivery.data", "delivery.intelligence"] unless defined? DELIVERY
  
rescue StandardError
  true
end