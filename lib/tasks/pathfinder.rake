namespace :pathfinder do

  require 'yaml'

  desc 'Generate Paths for Pathfinder.yml'
  task generate_paths: :environment do
    d = {}
    System.where.not(security_status: :wormhole).each do |sys|
      d[sys.name] = Pathfinder.dijkstra(sys, dst = nil)

    end
    File.open("#{Rails.root}/config/variables/pathfinder.yml", 'w') { |f| f.write d.to_yaml }
  end

  desc 'Generate Map Data for mapdata.yml'
  task generate_mapdata: :environment do
    d = { 'systems' => {}, 'jumpgates' => {} }
    System.where.not(security_status: :wormhole).each do |sys|
      d['systems'][sys.id] = { 'faction' => sys.get_faction&.get_ticker, 'name' => sys.name, 'security' => sys.security_status }
    end
    Jumpgate.includes(:origin, :destination).all.each do |jg|
      next if jg.origin&.wormhole? || jg.destination&.wormhole? || !jg.destination || !jg.origin
      d['jumpgates'][jg.id] = { 'from' => Location.find(jg.origin_id).system_id, 'to' => Location.find(jg.destination_id).system_id }
    end
    File.open("#{Rails.root}/config/variables/mapdata.yml", 'w') { |f| f.write d.to_yaml }
  end

end
