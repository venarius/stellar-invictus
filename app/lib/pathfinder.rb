class Pathfinder
    
  def self.find_path(start_id, end_id)
    start_system = System.find(start_id)
    end_system = System.find(end_id)
    
    shortest_path(start_system, end_system)
  end

  def self.dijkstra(system, dst = nil)
    distances = {}
    previouses = {}
    
    systems = System.all.pluck(:name)
    
    systems.each do |sys|
      distances[sys] = nil
      previouses[sys] = nil
    end
    
    distances[system.name] = 0
    
    until systems.empty?
      nearest_system = systems.inject do |a, b|
        next b unless distances[a]
        next a unless distances[b]
        next a if distances[a] < distances[b]
        b
      end
      
      break unless distances[nearest_system]
      if dst and nearest_system == dst
        return distances[dst]
      end
      
      neighbors = neighbors(nearest_system)
      neighbors.each do |sys|
        alt = distances[nearest_system] + get_traveltime_between(nearest_system, sys)
        if distances[sys].nil? or alt < distances[sys]
          distances[sys] = alt
          previouses[sys] = nearest_system
        end
      end
      
      systems.delete(nearest_system)
    end
    if dst
      return nil
    else
      return previouses
    end
  end
  
  def self.neighbors(name)
    neighbors = []
    System.find_by(name: name).locations.where(location_type: 'jumpgate').each do |location|
      neighbors << location.name
    end
    neighbors
  end
  
  def self.get_traveltime_between(start_sys, end_sys)
    System.find_by(name: start_sys).locations.where(name: end_sys, location_type: "jumpgate").each do |loc|
      return loc.jumpgate.traveltime
    end
  end
  
  def self.shortest_path(start_system, end_system)
    previouses = dijkstra(start_system)
    path = []
    u = end_system.name
    while u
      path.unshift(u)
      u = previouses[u]
    end
    return path
  end
  
end