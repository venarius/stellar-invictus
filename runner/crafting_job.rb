time = 0

while time < 50 do
  
  sleep(10)
  time = time + 10
  
  CraftJob.all.each do |job|
    if job.completion.utc < DateTime.now.utc
      if job.loader.include? "equipment."
        Item.give_to_user({loader: job.loader, user: job.user, location: job.location, amount: 1})
      else
        Spaceship.create(user_id: job.user.id, name: job.loader, hp: SHIP_VARIABLES[job.loader]['hp'], location: job.location)
      end
      
      # Increase Effiency
      blueprint = job.user.blueprints.find_by(loader: job.loader) rescue nil
      blueprint.update_columns(efficiency: blueprint.reload.efficiency - 0.025) if blueprint and blueprint.efficiency > 0.5
      
      job.destroy
    end
  end
end