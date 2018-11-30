begin

  SHIP_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/spaceships.yml")
  ITEM_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/items.yml")
  STATION_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/stations.yml")
  FACTION_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/factions.yml")
  
  # Spaceships
  if ActiveRecord::Base.connection.table_exists? 'spaceships'
    Spaceship.all.each do |ship|
       ship.update_columns(hp: SHIP_VARIABLES[ship.name]['hp']) 
    end
  end
  
  # Equipment
  EQUIPMENT = ["equipment.weapons.laser_gatling", "equipment.weapons.try_pyon_laser",
              "equipment.miner.advanced_miner", "equipment.miner.basic_miner", 
              "equipment.storage.small_black_hole", "equipment.defense.ion_shield",
              "equipment.defense.try_pyon_shield", "equipment.warp_core_stabilizers.warp_core_stabilizer",
              "equipment.hulls.light_hull", "equipment.scanner.small_scanner", 
              "equipment.repair_bots.simple_repair_bot", "equipment.warp_disruptors.basic_warp_disruptor"]
              
  # Materials
  MATERIALS = ["materials.sensor_electronics", "materials.antimatter", "materials.fusion_electronics",
              "materials.ai_components", "materials.metal_plates", "materials.laser_diodes"]
  
rescue StandardError
  true
end