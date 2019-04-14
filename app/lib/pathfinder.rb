class Pathfinder

  def self.find_path(start_id, end_id)
    start_system = System.find(start_id)
    end_system = System.find(end_id)

    shortest_path(start_system, end_system)
  end

  def self.dijkstra(system, dst = nil)
    distances = {}
    previouses = {}

    systems = System.where.not(security_status: :wormhole).pluck(:name)

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
      if dst && (nearest_system == dst)
        return distances[dst]
      end

      neighbors = neighbors(nearest_system)
      neighbors.each do |sys|
        alt = distances[nearest_system] + get_traveltime_between(nearest_system, sys)
        if distances[sys].nil? || (alt < distances[sys])
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
    System.ensure(name).locations.jumpgate.map(&:get_name)
  end

  def self.get_traveltime_between(start_sys, end_sys)
    # plus 20 because of align and warping to jumpgate
    System.ensure(start_sys).locations.jumpgate.where(name: end_sys).first.jumpgate.traveltime + 20
  end

  def self.shortest_path(start_system, end_system)
    previouses = System.pathfinder[start_system.name]
    path = []
    u = end_system.name
    while u
      path.unshift(u)
      u = previouses[u]
    end
    path
  end

end
