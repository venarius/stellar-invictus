# Asteroids
Location.where(location_type: 'asteroid_field').each do |loc|
  if loc.asteroids.count < 5
    if loc.system.low?
      rand(2..7).times do
        Asteroid.create(location: loc, asteroid_type: rand(6), resources: 350000)
      end
    elsif loc.system.wormhole?
      rand(1..3).times do
        Asteroid.create(location: loc, asteroid_type: 6, resources: 350000)
      end
    else
      rand(2..5).times do
        Asteroid.create(location: loc, asteroid_type: rand(4), resources: 350000)
      end
    end
  end
end
