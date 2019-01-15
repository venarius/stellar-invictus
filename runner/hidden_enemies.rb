User.where.not(online: 0).order(Arel.sql("RANDOM()")).limit(20).each do |user|
  if (user.location.mission? || user.location.exploration_site?) and user.can_be_attacked
    if rand(1..11) == 11
      rand(1..3).times do
        EnemyWorker.perform_async(nil, user.location_id, nil, nil, nil, true)
      end
    end
  end
end