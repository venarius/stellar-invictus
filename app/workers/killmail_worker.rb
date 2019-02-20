class KillmailWorker
  # This Worker will be run when a player is mining something
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(attr, attackers=nil, loot=nil)
    uri = URI(ENV.fetch("KILLBOARD_URL") { "http://killboard.mdotshell.com:8080/submit" })
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    
    body = attr
    
    if attackers and attackers != []
      temp = []
      attackers.each do |at|
        hash = {}
        attacker = User.find(at) rescue nil
        next unless attacker
        hash['id'] = attacker.id
        hash['name'] = attacker.full_name
        hash['avatar'] = attacker.avatar
        hash['ship_name'] = attacker.active_spaceship.name
        hash['bounty'] = attacker.bounty
        
        if attacker.corporation
          hash['corporation'] = {id: attacker.corporation.id, ticker: attacker.corporation.ticker, name: attacker.corporation.name}
        end
        
        temp << hash
      end
      body.reverse_merge!({killers: temp})
    else
      body.reverse_merge!({killers: ["npc"]})
    end
    
    if loot and loot != []
      body.reverse_merge!({loot: loot})
    end
    
    #logger.info({kill: body}.to_json)
    
    req.body = {kill: body}.to_json
    Net::HTTP.start(uri.hostname, uri.port, :read_timeout => 10) do |http|
      http.request(req)
    end
  end
end