class StructuresController < ApplicationController

  def open_container
    container = Structure.ensure(params[:id])
    raise InvalidRequest if !container || (container.location_id != current_user.location_id) || !current_user.can_be_attacked?

    owner_name = ''
    owner_name = container.user.full_name if container.container?

    render partial: 'structures/cargocontainer',
           locals: { items: container.get_items, container_id: container.id, owner_name: owner_name },
           status: :ok
  end

  def pickup_cargo
    structure = Structure.ensure(params[:id])
    raise InvalidRequest if !structure || !current_user.can_be_attacked? || (structure.location_id != current_user.location_id)

    items = Item.where(structure: structure)
    items = items.where(loader: params[:loader]) if params[:loader]

    # Call police
    if (structure.user != current_user) &&
       (structure.structure_type != 'wreck' &&
       !structure.user.in_same_fleet_as(current_user) &&
       (structure.created_at > (DateTime.now.to_time - 10.minutes).to_datetime))
      call_police(current_user)
    end

    # Check if player has enough space
    free_weight = current_user.active_spaceship.get_free_weight
    item_count = 0
    count = 0
    items.each do |item|
      item_count = item_count + item.count
      if item.get_attribute('weight') <= free_weight
        amount = (free_weight / item.get_attribute('weight')).round
        amount = item.count if amount > item.count
        Item::GiveToUser.(loader: item.loader, user: current_user, amount: amount)
        amount >= item.count ? item.destroy : item.update(count: item.count - amount)
        free_weight -= item.get_attribute('weight') * amount
        count += amount
      end
    end

    # Destroy Structure if items gone and tell players to update players
    if structure.items.count == 0
      structure.destroy
      current_user.location.broadcast(:player_appeared)
    end

    raise InvalidRequest.new('errors.your_ship_cant_carry_that_much') if count.zero?

    json_result = {}
    if !params[:loader] || (count != item_count)
      json_result = { amount: item_count - free_weight }
    end

    render json: json_result, status: :ok
  end

  def attack
    structure = Structure.ensure(params[:id])
    raise InvalidRequest if !structure || !current_user.can_be_attacked? || (structure.location_id != current_user.location_id)

    # Call police
    if (structure.user != current_user) &&
       (structure.structure_type != 'wreck') &&
       !structure.user.in_same_fleet_as(current_user) &&
       (structure.created_at > (DateTime.now.to_time - 10.minutes).to_datetime)
      call_police(current_user)
    end

    # Destroy Structure
    structure.destroy

    # Tell Players in location
    current_user.location.broadcast(:player_appeared)
    current_user.location.broadcast(:log,
      text: I18n.t('log.user_destroyed_cargo', user: current_user.full_name)
    )

    render json: {}, status: :ok
  end

  def abandoned_ship
    structure = Structure.ensure(params[:id])
    raise InvalidRequest if !structure || !current_user.can_be_attacked? || (structure.location_id != current_user.location_id)

    if params[:text] && structure.items.present?
      if structure.correct_answer?(params[:text])
        new_structure = Structure.create(location: current_user.location, structure_type: :wreck)
        structure.items.update_all(structure_id: new_structure.id)
      else
        rand(2..4).times do
          EnemyWorker.perform_async(nil, current_user.location.id)
        end
        structure.increment!(:attempts)
        if structure.attempts > 5
          structure.destroy
          current_user.location.broadcast(:player_appeared)
          current_user.broadcast(:notify_alert, text: I18n.t('structures.abandoned_ship_selfdestruction'))
        end
        raise InvalidRequest
      end
    else
      render partial: 'structures/abandoned_ship', locals: { structure: structure }, status: :ok
      return
    end

    render json: {}, status: :ok
  end

  def monument_info
    structure = Structure.ensure(params[:id])
    raise InvalidRequest if !structure || !current_user.can_be_attacked? || (structure.location_id != current_user.location_id)

    render partial: 'structures/monument', locals: { structure: structure }, status: :ok
  end

end
