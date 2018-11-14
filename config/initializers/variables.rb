SHIP_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/spaceships.yml")
ITEM_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/items.yml")
STATION_VARIABLES = YAML.load_file("#{Rails.root.to_s}/config/variables/stations.yml")

# Spaceships
if ActiveRecord::Base.connection.table_exists? 'spaceships'
  Spaceship.all.each do |ship|
     ship.update_columns(hp: SHIP_VARIABLES[ship.name]['hp']) 
  end
end