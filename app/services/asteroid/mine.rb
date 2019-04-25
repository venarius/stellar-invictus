class Asteroid::Mine < ApplicationService
  required :asteroid, ensure: Asteroid
  required :user, ensure: User

  def perform
    # Explicit error conditions
    fail!(I18n.t('errors.cant_mine_in_warp')) if user.in_warp?
    fail!(I18n.t('errors.cant_mine_when_docked')) if user.docked?
    fail!(I18n.t('errors.nothing_to_mine')) unless user.location.asteroids.present?
    fail!(I18n.t('errors.something_went_wrong')) unless user.can_be_attacked?

    # If user can't carry ore -> error
    if user.active_spaceship.get_weight >= user.active_spaceship.get_storage_capacity
      fail!(I18n.t('errors.your_ship_cant_carry_that_much'))
    end

    # If user has no mining laser equipped -> error
    if user.active_spaceship.get_mining_amount == 0
      fail!(I18n.t('errors.no_mining_laser'))
    end

    # If asteroid has no resources -> error
    if asteroid.resources.zero? || (asteroid.location != user.location)
      fail!(I18n.t('errors.nothing_to_mine'))
    end

    if (user.mining_target == asteroid)
      fail!(I18n.t('errors.already_mining'))
    end

    # Perform Mining Worker
    MiningWorker.perform_async(user.id, asteroid.id)

    {
      name: "#{I18n.t('overview.asteroid')} #{asteroid.asteroid_type.capitalize}",
      resources: asteroid.resources
    }
  end
end
