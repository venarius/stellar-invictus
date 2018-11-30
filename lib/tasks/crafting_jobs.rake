namespace :crafting_jobs do
  
  desc "Finish CraftJobs"
  
  task finish: :environment do
    time = 0
    while time < 50 do
      time = time + 10
      CraftJob.all.each do |job|
        if job.completion.utc < DateTime.now.utc
          if job.loader.include? "equipment."
            Item.create(loader: job.loader, user: job.user, location: job.location, active: false, equipped: false)
          else
            Spaceship.create(user_id: job.user.id, name: job.loader, hp: SHIP_VARIABLES[job.loader]['hp'])
          end
          job.destroy
        end
      end
      sleep(10)
    end
  end
  
end