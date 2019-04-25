# == Schema Information
#
# Table name: npcs
#
#  id          :bigint(8)        not null, primary key
#  hp          :integer
#  name        :string
#  npc_state   :integer
#  npc_type    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint(8)
#  target_id   :integer
#
# Indexes
#
#  index_npcs_on_location_id  (location_id)
#  index_npcs_on_npc_type     (npc_type)
#  index_npcs_on_target_id    (target_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

class Npc < ApplicationRecord
  include ApplicationHelper

  ## -- RELATIONSHIPS
  belongs_to :location, optional: true
  belongs_to :target, class_name: User.name, foreign_key: :target_id, optional: true

  ## -- ATTRIBUTES
  enum npc_type: [:enemy, :police, :politician, :bodyguard, :wanted_enemy]
  enum npc_state: [:created, :targeting, :attacking, :waiting]

  ## -- SCOPES
  scope :targeting_user, ->(user) { where(target: user) }

  ## -- CALLBACKS
  before_validation :set_name

  ## — CLASS METHODS
  def self.random_name
    "#{Faker::Name.first_name} #{Faker::Name.last_name}"
  end

  ## — INSTANCE METHODS
  def find_enemy_target
    self.location.random_online_in_space_user
  end

  def die
    NpcDiedWorker.perform_async(self.id)
  end

  def drop_loot
    if self.location.exploration_site?
      loader = Item::MATERIALS
      loader = loader + ['asteroid.lunarium_ore'] if self.location.system.wormhole?
      case rand(1..100)
      when 1..75
        loader = Item::EQUIPMENT_EASY + loader
      when 76..95
        loader = Item::EQUIPMENT_MEDIUM + loader
      when 96..100
        loader = Item::EQUIPMENT_HARD + loader
      end

      # Drop Passengers if last NPC or wanted enemy
      if ((self.location.name == I18n.t('exploration.emergency_beacon')) && (self.location.npcs.count == 1)) || (self.wanted_enemy? && (rand(1..5) == 5))
        structure = Structure.create(location: self.location, structure_type: :wreck)
        Item.create(structure: structure, loader: 'delivery.passenger', count: rand(1..5))
      end
    else
      loader = Item::MATERIALS
    end

    structure = Structure.create(location: self.location, structure_type: :wreck)
    Item.create(loader: loader.sample, structure: structure, equipped: false, count: rand(1..3))
    Item.create(loader: Item::MATERIALS.sample, structure: structure, equipped: false, count: rand(3..6))
  end

  def drop_blueprint(user)
    if rand(1..2) == 1
      loader = Item::EQUIPMENT.sample
      if !user.has_blueprints_for?(loader)
        user.give_blueprints_for(loader, efficiency: 1)
        user.broadcast(:notify_alert,
          text: I18n.t('notification.received_blueprint_destruction',
            name: Item.get_attribute(loader, :name),
            npc: self.name)
          )
      end
    else
      random_ship = Spaceship.get_attributes.keys.sample
      if !user.has_blueprints_for?(random_ship)
        user.give_blueprints_for(random_ship, efficiency: 1)
        user.broadcast(:notify_alert,
          text: I18n.t('notification.received_blueprint_destruction',
            name: random_ship.titleize,
            npc: self.name)
          )
      end
    end
  end

  def remove_being_targeted
    User.where(npc_target_id: self.id).each do |user|
      user.update(npc_target_id: nil, is_attacking: false)
      user.broadcast(:remove_target)
    end
  end

  def give_bounty(player)

    value = rand(5..15)

    value = value * 3 if self.location.system.low? || self.location.exploration_site? || self.politician?

    value = value * 50 if self.wanted_enemy?

    value = value * 100 if self.location.system.wormhole?

    player.give_units(value)

    # Also give reputation
    corporation = player.system.locations.station.first&.faction&.id
    if corporation
      amount = 0.01
      amount = amount * 3 if self.wanted_enemy?
      player.broadcast(:notify_alert, text: I18n.t('notification.gained_reputation', user: self.name, amount: amount))
      case corporation
      when 1
        player.update(reputation_1: player.reputation_1 + amount)
      when 2
        player.update(reputation_2: player.reputation_2 + amount)
      when 3
        player.update(reputation_3: player.reputation_3 + amount)
      end
    end

    player.broadcast(:notify_alert, text: I18n.t('notification.received_bounty', user: self.name, amount: value))
    player.broadcast(:refresh_player_info)
  end

  private

  def set_name
    self.name ||= self.class.random_name
  end
end
