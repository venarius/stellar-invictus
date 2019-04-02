class User < ApplicationRecord

  acts_as_voter

  ## -- RELATIONSHIPS
  belongs_to :faction, optional: true
  belongs_to :system, optional: true
  belongs_to :location, optional: true
  belongs_to :fleet, optional: true
  belongs_to :corporation, optional: true

  belongs_to :target, class_name: User.name, foreign_key: :target_id, optional: true
  belongs_to :active_spaceship, class_name: Spaceship.name, foreign_key: :active_spaceship_id, optional: true
  belongs_to :mining_target, class_name: Asteroid.name, foreign_key: :mining_target_id, optional: true
  belongs_to :npc_target, class_name: Npc.name, foreign_key: :npc_target_id, optional: true

  has_many :chat_messages, dependent: :destroy
  has_many :spaceships, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :craft_jobs, dependent: :destroy
  has_many :missions, dependent: :destroy
  has_many :blueprints, dependent: :destroy
  has_many :market_listings, dependent: :destroy

  has_and_belongs_to_many :chat_rooms

  ## -- ATTRIBUTES
  enum corporation_role: [:recruit, :lieutenant, :commodore, :admiral, :founder]

  delegate :name, :security_status, to: :system, prefix: true
  delegate :location_type, :enemy_amount, to: :location, prefix: true
  delegate :name, to: :faction, prefix: true
  delegate :name, :ticker, to: :corporation, prefix: true

  ## -- VALIDATIONS
  validates :name, :family_name, :avatar, presence: true
  validates :name, uniqueness: { scope: :family_name }
  validates :email, uniqueness: true
  validates_format_of :name, :family_name, with: /\A[a-zA-Z]+\z/i, message: I18n.t('validations.can_only_contain_letters')
  validates :name, :family_name, length: { minimum: 2, maximum: 20,
                                           too_short: I18n.t('validations.too_short_2'), too_long: I18n.t('validations.too_long_name') }

  validate :check_avatar, on: :create

  # Devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[facebook]

  ## -- SCOPES
  scope :targeting_user, ->(user) { where(target: user) }

  ## -- CALLBACKS
  # Sets full name after create
  before_save do
    self.full_name = "#{name} #{family_name}".downcase.titleize
  end

  before_destroy do
    self.corporation.destroy if self.founder? && self.corporation # corporation
    Friendship.where(friend_id: self.id).destroy_all # friendships
    GameMail.where(sender_id: self.id).destroy_all # game mails
  end

  ## — CLASS METHODS
  # Overridden from Devise to eager_load(:system, :active_spaceship)
  def self.serialize_from_session(key, salt)
    record = where(id: key).eager_load(:system, :active_spaceship).first
    record if record && record.authenticatable_salt == salt
  end

  # Verify Avatar
  def check_avatar
    unless %w(M_1 M_2 M_3 M_4 M_5 M_6 M_7 M_8 M_9 M_10 M_11 M_12 M_13 M_14 M_15 M_16 M_17
              F_1 F_2 F_3 F_4 F_5 F_6 F_7 F_8 F_9 F_10 F_11 F_12 F_13 F_14 F_15).include?(self.avatar)
      errors.add(:avatar, "has not a correct value")
    end
  end

  # Will be called when a user loggs in
  def appear
    AppearWorker.perform_async(self.id)
  end

  # Will be called when a user loggs off
  def disappear
    self.update_columns(target_id: nil) && DisappearWorker.perform_async(self.id)
  end

  # Returns if player can be attacked
  def can_be_attacked
    !docked && !in_warp && (online > 0) && ((self.active_spaceship.hp rescue 0) > 0)
  end

  # Lets the player die
  def die(police = false, attackers = nil)
    # Get old System
    old_system = System.find(self.system_id)

    loot = self.active_spaceship.drop_loot if self.active_spaceship

    # Run Killmail Worker
    hash = { id: self.id, full_name: self.full_name, avatar: self.avatar, ship_name: self.active_spaceship.name,
             bounty: self.bounty, system_name: old_system.name, site_name: self.location.get_name }
    hash.reverse_merge!(corporation: { id: self.corporation.id, name: self.corporation.name, ticker: self.corporation.ticker }) if self.corporation
    KillmailWorker.perform_async(hash, attackers, loot)

    # Get ActionCable Server
    ac_server = ActionCable.server

    # Tell others in system that player "warped out"
    ac_server.broadcast("location_#{self.location.id}", method: 'player_warp_out', name: self.full_name)
    ac_server.broadcast("location_#{self.location.id}", method: 'log', text: I18n.t('log.got_killed', name: self.full_name))

    # Create Wreck and fill with random loot
    self.active_spaceship.deactivate_equipment
    ac_server.broadcast("location_#{self.location.id}", method: 'player_appeared')

    # Destroy current spaceship of user and give him a nano if not insured
    old_ship = self.active_spaceship.destroy if self.active_spaceship
    if old_ship&.insured && !police
      spaceship = Spaceship.create(user_id: self.id, name: old_ship.name, hp: Spaceship.get_attribute(old_ship.name, :hp))
      self.update_columns(active_spaceship_id: spaceship.id)
    else
      self.give_nano
    end

    # Make User docked at his factions station
    rand_location = self.faction.locations.where(location_type: :station).order(Arel.sql("RANDOM()")).first rescue nil
    self.update_columns(in_warp: false, docked: true, location_id: rand_location.id, system_id: rand_location.system.id, target_id: nil, mining_target_id: nil, npc_target_id: nil)

    # Tell user to reload page
    ac_server.broadcast("player_#{self.id}", method: 'reload_page')

    # Tell everyone in new system to update their local players
    old_system.update_local_players

    PlayerDiedWorker.perform_in(1.second, self.id)
  end

  # Returns if user is in same fleet with given id
  def in_same_fleet_as(other_user)
    self.fleet_id && self.fleet_id == other_user.fleet_id
  end

  # Returns if user is in same fleet with given id
  def in_same_corporation_as(other_user)
    self.corporation_id && self.corporation_id == other_user.corporation_id
  end

  # Gets the user remove being a target of other players
  def remove_being_targeted
    Npc.targeting_user(self).update_all(target: nil)
    User.targeting_user(self).each do |user|
      user.update_columns(target_id: nil)
      user.active_spaceship.deactivate_equipment if user.is_attacking?
      ActionCable.server.broadcast("player_#{user.id}", method: 'remove_target')
    end
  end

  # Docks the player
  def dock
    self.update_columns(docked: true, target_id: nil)
    ActionCable.server.broadcast("location_#{self.location.id}", method: 'player_warp_out', name: self.full_name)
    remove_being_targeted
  end

  # Undocks the player
  def undock
    if self.docked
      self.update_columns(docked: false)
      ActionCable.server.broadcast("location_#{self.location.id}", method: 'player_appeared')
    end
  end

  # Returns if player can buy a ship
  def can_buy_ship(name)
    ship_vars = Spaceship.get_attribute(name)
    ship_vars && (self.units >= ship_vars['price']) && self.location.get_ships_for_sale.has_key?(name)
  end

  # Reduce the user's units
  def reduce_units(amount)
    self.update_columns(units: self.reload.units - amount)
  end

  # Give the user units
  def give_units(amount)
    if self.corporation && (self.corporation.tax > 0)
      new_amount = amount - amount * (self.corporation.tax / 100)
      self.corporation.update_columns(units: self.corporation.units + (amount - new_amount))
      self.update_columns(units: self.reload.units + new_amount)
    else
      self.update_columns(units: self.reload.units + amount)
    end
  end

  # Give user a nano
  def give_nano
    spaceship = Spaceship.create(user_id: self.id, name: 'Nano', hp: 150)
    Item.create(loader: 'equipment.miner.basic_miner', spaceship: spaceship, equipped: true)
    Item.create(loader: 'equipment.weapons.laser_gatling', spaceship: spaceship, equipped: true)
    self.update_columns(active_spaceship_id: spaceship.id)
  end

  # Give bounty to player (50% share of loss)
  def give_bounty(player)
    if self.bounty > 0
      value = (self.active_spaceship.get_total_value * 0.5).round

      if value <= self.bounty
        self.update_columns(bounty: self.bounty - value)
      else
        value = self.bounty
        self.update_columns(bounty: 0)
      end

      player.update_columns(bounty_claimed: player.reload.bounty_claimed + value)
      player.give_units(value)

      ActionCable.server.broadcast("player_#{player.id}", method: 'notify_alert', text: I18n.t('notification.received_bounty', user: self.full_name, amount: value))
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_player_info')
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.password = Devise.friendly_token[0, 20]
        user.uid = session["devise.facebook_data"]["uid"]
        user.provider = session["devise.facebook_data"]["provider"]
        user.skip_confirmation!
      end
    end
  end

  # Teleports to another user
  def teleport(user)
    ActionCable.server.broadcast("location_#{location_id}", method: 'player_warp_out', name: full_name)
    old_system = self.system
    self.update_columns(location_id: user.location_id, system_id: user.system_id, docked: user.docked, in_warp: false)
    # Tell everyone in old system to update their local players
    old_system.update_local_players
    # Tell everyone in new system to update their local players
    self.reload.system.update_local_players
    ActionCable.server.broadcast("location_#{location_id}", method: 'player_appeared')
    ActionCable.server.broadcast("player_#{id}", method: 'warp_finish')
  end

  # Ban User
  def ban(duration, reason)
    if duration.to_i == 0
      self.update_columns(banned: true, banned_until: nil, banreason: reason)
    else
      self.update_columns(banned: true, banned_until: (DateTime.now.to_time + duration.to_i.hours).to_datetime , banreason: reason)
    end
    ActionCable.server.broadcast("player_#{id}", method: 'reload_page')
  end

  # Unban User
  def unban
    self.update_columns(banned: false, banned_until: nil, banreason: nil) if banned
  end

end
