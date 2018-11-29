class CraftingWorker
  # Checks for finished crafting jobs
  
  include Sidekiq::Worker
  sidekiq_options :retry => false 
  
  def perform(user_id)
    # Get user
    user = User.find(user_id)
    
    # Do Stuff
    CraftJob.where(user: user, location: user.location).each do |job|
      if job.completion.utc < DateTime.now.utc
        Item.create(loader: job.loader, user: job.user, location: job.location)
        job.destroy
      end
    end
      
  end
  
end