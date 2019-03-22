User.where.not(online: 0).order(Arel.sql("RANDOM()")).limit(20).each do |user|
  if (user.location.mission? || user.location.exploration_site?) && (user.location_enemy_amount > 0) && user.can_be_attacked
    if rand(1..6) == 6
      rand(2..4).times do
        EnemyWorker.perform_async(nil, user.location_id)
      end
    end
  end
end
