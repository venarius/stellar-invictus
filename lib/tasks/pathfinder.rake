namespace :pathfinder do
  
  require 'yaml'
  
  desc "Generate Paths for Pathfinder.yml"
  task :generate_paths => :environment do
    d = {}
    System.all.each do |sys|
      d[sys.name] = Pathfinder.dijkstra(sys, dst = nil)
      
    end
    File.open("#{Rails.root.to_s}/config/variables/pathfinder.yml", 'w') {|f| f.write d.to_yaml }
  end
end