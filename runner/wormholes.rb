ac_server = ActionCable.server

if System.where(security_status: :wormhole).count < 15

  systems = []

  # Wormhole Systems
  rand(5..10).times do
    systems << System.create(name: "Unknown", security_status: :wormhole)
  end

  # Stuff generation
  systems.each do |sys|
    s = System.where.not(security_status: :wormhole).where(security_status: :low).order(Arel.sql("RANDOM()")).first

    # Jumpgates
    a = Location.find_or_create_by(name: sys.name, system: s, location_type: 5, hidden: true)
    b = Location.find_or_create_by(name: s.name, system: sys, location_type: 5, hidden: true)
    Jumpgate.find_or_create_by(origin: a, destination: b, traveltime: 5)

    # Asteroid Belts
    romans = ["I", "II", "III", "IV", "V", "VI"]
    count = 0
    if sys.locations.where(location_type: 1).empty?
      (rand(0..3)).times do
        loc = Location.find_or_create_by(name: "#{romans[count]}", system: sys, location_type: 1)
        count = count + 1

        # Asteroids
        rand(2..5).times do
          Asteroid.create(location: loc, asteroid_type: [0, 1, 2].sample, resources: 35000)
        end
        rand(1..3).times do
          Asteroid.create(location: loc, asteroid_type: 6, resources: 35000)
        end
      end
    end

    # Combat Sites
    rand(1..3).times do
      location = Location.create(system: sys, location_type: 'exploration_site', hidden: true)
      amount = rand(4..10)
      location.update_columns(enemy_amount: amount, name: I18n.t('exploration.combat_site'))
    end
  end

else

  # Delete Wormholes
  rand(2..4).times do
    sys = System.where(security_status: :wormhole).order(Arel.sql("RANDOM()")).first
    if sys.users.empty?
      sys.locations.where(location_type: 5).each do |loc|
        loc.jumpgate.destroy if loc.jumpgate
      end
      sys.destroy
    end
  end

end

# Random Exit Spawner and Despawner
System.where(security_status: :wormhole).each do |sys|
  if (rand(1..2) == 2) && sys.locations.where(location_type: 5).present?
    sys.locations.where(location_type: 5).each do |loc|
      if loc.jumpgate
        origin = loc.jumpgate.origin_id
        loc.jumpgate.destroy

        # Tell players
        ac_server.broadcast("location_#{loc.id}", method: 'player_appeared')
        ac_server.broadcast("location_#{origin}", method: 'player_appeared') if origin
      else
        s = System.where(security_status: :low).order(Arel.sql("RANDOM()")).first

        a = Location.find_or_create_by(name: sys.name, system: s, location_type: 5, hidden: true)
        Jumpgate.find_or_create_by(origin: a, destination: loc, traveltime: 5)
        loc.update_columns(name: s.name)

        # Tell players
        ac_server.broadcast("location_#{loc.id}", method: 'player_appeared')
        ac_server.broadcast("location_#{a.id}", method: 'player_appeared')
      end
    end
  elsif sys.locations.where(location_type: 5).empty?
    s = System.where(security_status: :low).order(Arel.sql("RANDOM()")).first

    # Jumpgates
    a = Location.find_or_create_by(name: sys.name, system: s, location_type: 5, hidden: true)
    b = Location.find_or_create_by(name: s.name, system: sys, location_type: 5, hidden: true)
    Jumpgate.find_or_create_by(origin: a, destination: b, traveltime: 5)

    # Tell players
    ac_server.broadcast("location_#{a.id}", method: 'player_appeared')
    ac_server.broadcast("location_#{b.id}", method: 'player_appeared')
  end
end

# Junk Cleaner
Location.where(location_type: :wormhole).each do |loc|
  if !loc.jumpgate || loc.jumpgate.destination == nil || loc.jumpgate.origin == nil
    loc.destroy if loc.users.empty? && Spaceship.where(warp_target_id: loc.id).empty?
  end
end
