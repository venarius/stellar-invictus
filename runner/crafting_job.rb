time = 0

while time < 50 do

  sleep(10)
  time = time + 10

  CraftJob.where("completed_at < ?",Time.now.utc).each do |job|
    if job.loader.include? "equipment."
      Item::GiveToUser.(loader: job.loader, user: job.user, location: job.location, amount: 1)
    else
      Spaceship.create(user_id: job.user.id, name: job.loader, hp: Spaceship.get_attribute(job.loader, :hp), location: job.location)
    end

    # Increase Effiency
    blueprint = job.user.blueprints.where(loader: job.loader).first
    blueprint.update(efficiency: blueprint.reload.efficiency - 0.025) if blueprint && (blueprint.efficiency > 0.5)

    job.destroy
  end
end
