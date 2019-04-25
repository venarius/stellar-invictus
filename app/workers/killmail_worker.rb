class KillmailWorker < ApplicationWorker
  # This Worker will be run when a player is mining something
  def perform(body, attackers = nil, loot = nil)
    return if Rails.env.test? # Do nothing when testing

    uri = URI(ENV.fetch('KILLBOARD_URL', 'https://killboard.stellar-invictus.com/'))
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

    if attackers && (attackers != [])
      temp = []
      attackers.each do |attacker|
        attacker = User.ensure(attacker)
        next unless attacker

        hash = {
          'id' => attacker.id,
          'name' => attacker.full_name,
          'avatar' => attacker.avatar,
          'ship_name' => attacker.active_spaceship.name,
          'bounty' => attacker.bounty
        }
        if attacker.corporation
          hash['corporation'] = {
            id: attacker.corporation.id,
            ticker: attacker.corporation.ticker,
            name: attacker.corporation.name
          }
        end

        temp << hash
      end
      body.reverse_merge!(killers: temp)
    else
      body.reverse_merge!(killers: ['npc'])
    end

    if loot && (loot != [])
      body.reverse_merge!(loot: loot)
    end

    req.body = { kill: body }.to_json
    Net::HTTP.start(uri.hostname, uri.port, read_timeout: 10, use_ssl: true) do |http|
      http.request(req)
    end
  end
end
