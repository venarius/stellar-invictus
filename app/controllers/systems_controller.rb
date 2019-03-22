class SystemsController < ApplicationController

  def info
    if params[:id]
      system = System.find(params[:id]) rescue nil
      if system
        render(partial: 'systems/info', locals: { sys: system }) && (return)
      end
    end
    render json: {}, status: 400
  end

  def route
    if params[:id]
      system = System.find(params[:id]) rescue nil
      if system && !current_user.system.wormhole?
        old_route = current_user.route
        path = Pathfinder.find_path(current_user.system.id, system.id)

        jumpgates = []
        path.each_with_index do |step, index|
          location = System.find_by(name: step).locations.where("name ilike ?", path[index + 1]).first
          jumpgates << location.jumpgate.id if location
        end

        current_user.update_columns(route: jumpgates)
        render(json: { old_route: old_route, route: jumpgates, card: render_to_string(partial: 'systems/route_card') }, status: 200) && (return)
      end
    end
    render json: {}, status: 400
  end

  def clear_route
    old_route = current_user.route
    current_user.update_columns(route: [])
    render json: { route: old_route }, status: 200
  end

  def scan
    scanner_range = current_user.active_spaceship.get_scanner_range
    if scanner_range && current_user.can_be_attacked
      # check count
      render(json: { error_message: I18n.t('errors.no_exploration_sites_found') }, status: 400) && (return) if current_user.system.locations.where(hidden: true).count == 0

      render partial: 'game/locations_table', locals: { locations: current_user.system.locations.where(hidden: true).limit(scanner_range) }
    else
      render json: {}, status: 400
    end
  end

  def directional_scan
    scanner_range = current_user.active_spaceship.get_scanner_range

    if current_user.can_be_attacked
      locations = {}
      current_user.system.locations.where(hidden: false).each do |loc|
        locations[loc.id] = loc.users.where.not(online: 0).count + loc.npcs.count
      end

      if scanner_range
        current_user.system.locations.where(hidden: true).limit(scanner_range).each do |loc|
          locations[loc.id] = loc.users.where.not(online: 0).count + loc.npcs.count
        end
      end

      render(json: { locations: locations }, status: 200) && (return)
    end
    render json: {}, status: 400
  end

  def jump_drive
    if params[:id] && current_user.active_spaceship.get_jump_drive && current_user.can_be_attacked
      system = System.find(params[:id]) rescue nil

      # Check Warp Disrupt
      if current_user.active_spaceship.is_warp_disrupted
        render(json: { 'error_message' => I18n.t('errors.warp_disrupted') }, status: 400) && (return)
      end

      # Check in combat
      if User.where(target_id: current_user.id, is_attacking: true).count > 0 || Npc.where(target: current_user.id).count > 0
        render(json: { 'error_message' => I18n.t('errors.cant_do_that_whilst_in_combat') }, status: 400) && (return)
      end

      if system && (system.medium? || system.high?) && (current_user.system.medium? || current_user.system.high?)
        ship_align = current_user.active_spaceship.get_align_time
        traveltime = 0

        path = Pathfinder.find_path(current_user.system.id, system.id)
        path.each_with_index do |step, index|
          location = System.find_by(name: step).locations.where("name ilike ?", path[index + 1]).first
          traveltime = traveltime + location.jumpgate.traveltime if location
          traveltime = traveltime + ship_align + 10
        end

        JumpWorker.perform_async(current_user.id, false, (traveltime * 0.75).round, system.id)
        render(json: { traveltime: (traveltime * 0.75).round }, status: 200) && (return)
      end
    end
    render json: {}, status: 400
  end

end
