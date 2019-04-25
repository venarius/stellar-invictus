class SystemsController < ApplicationController

  def info
    system = System.ensure(params[:id])
    raise InvalidRequest unless system

    render(partial: 'systems/info', locals: { sys: system })
  end

  def route
    system = System.ensure(params[:id])
    raise InvalidRequest if !system || current_user.system.wormhole?

    old_route = current_user.route
    path = Pathfinder.find_path(current_user.system.id, system.id)

    jumpgates = []
    path.each_with_index do |step, index|
      location = System.ensure(step).locations.where('name ILIKE ?', path[index + 1]).first
      jumpgates << location.jumpgate.id if location
    end

    current_user.update(route: jumpgates)
    render json: { old_route: old_route, route: jumpgates, card: render_to_string(partial: 'systems/route_card') }, status: :ok
  end

  def clear_route
    old_route = current_user.route
    current_user.update(route: [])
    render json: { route: old_route }, status: :ok
  end

  def scan
    scanner_range = current_user.active_spaceship.get_scanner_range
    raise InvalidRequest if !scanner_range || !current_user.can_be_attacked?
    cur_system = current_user.system

    raise InvalidRequest.new('errors.no_exploration_sites_found') if cur_system.locations.is_hidden.count == 0

    render partial: 'game/locations_table', locals: { locations: cur_system.locations.is_hidden.limit(scanner_range) }
  end

  def directional_scan
    scanner_range = current_user.active_spaceship.get_scanner_range
    raise InvalidRequest unless current_user.can_be_attacked?
    cur_system = current_user.system

    locations = {}
    cur_system.locations.not_hidden.each do |loc|
      locations[loc.id] = loc.users.is_online.count + loc.npcs.count
    end

    if scanner_range
      cur_system.locations.is_hidden.limit(scanner_range).each do |loc|
        locations[loc.id] = loc.users.is_online.count + loc.npcs.count
      end
    end

    render json: { locations: locations }, status: :ok
  end

  def jump_drive
    system = System.ensure(params[:id])
    raise InvalidRequest if !system || !current_user.active_spaceship.has_jump_drive? || !current_user.can_be_attacked?

    # Check Warp Disrupt
    raise InvalidRequest.new('errors.warp_disrupted') if current_user.active_spaceship.is_warp_disrupted?

    # Check in combat
    if User.targeting_user(current_user).where(is_attacking: true).exists? ||
       Npc.targeting_user(current_user).exists?
      raise InvalidRequest.new('errors.cant_do_that_whilst_in_combat')
    end

    raise InvalidRequest if !%w[medium high].include?(system.security_status) || !%w[medium high].include?(current_user.system.security_status)

    ship_align = current_user.active_spaceship.get_align_time
    traveltime = 0

    path = Pathfinder.find_path(current_user.system.id, system.id)
    path.each_with_index do |step, index|
      location = System.ensure(step).locations.where('name ILIKE ?', path[index + 1]).first
      traveltime += location.jumpgate.traveltime if location
      traveltime += ship_align + 10
    end

    JumpWorker.perform_async(current_user.id, false, (traveltime * 0.75).round, system.id)
    render json: { traveltime: (traveltime * 0.75).round }, status: :ok
  end

end
