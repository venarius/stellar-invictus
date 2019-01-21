# Asteroids
Location.where(location_type: 'asteroid_field').each do |loc|
  if loc.asteroids.count < 5
    if loc.system.low?
      rand(2..5).times do 
        Asteroid.create(location: loc, asteroid_type: [0,1,2].sample, resources: 35000)
      end
      rand(1..3).times do
        Asteroid.create(location: loc, asteroid_type: 5, resources: 35000)
      end
    else
      rand(2..5).times do 
        Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
      end
    end
    rand(1..3).times do 
      Asteroid.create(location: loc, asteroid_type: 3, resources: 35000)
    end
  end
end